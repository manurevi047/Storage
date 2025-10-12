import express from 'express';
import cors from 'cors';
import multer from 'multer';
import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import fs from 'fs';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Supabase client
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;
const supabaseBucket = process.env.SUPABASE_BUCKET || 'uploads';

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing SUPABASE_URL or SUPABASE_KEY environment variables');
  process.exit(1);
}

// Validate Supabase URL format
if (supabaseUrl.includes('/storage/v1/s3')) {
  console.error('❌ ERROR: SUPABASE_URL should be your project URL, not the storage endpoint!');
  console.error('Expected format: https://YOUR_PROJECT_REF.supabase.co');
  console.error('Current value:', supabaseUrl);
  console.error('Remove ".storage" and "/storage/v1/s3" from the URL');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);
console.log('✅ Supabase client initialized with URL:', supabaseUrl);

// Middleware to verify JWT token
const verifyAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No authorization token provided' });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    // Verify the JWT token with Supabase
    const { data: { user }, error } = await supabase.auth.getUser(token);
    
    if (error || !user) {
      console.error('Auth verification failed:', error);
      return res.status(401).json({ error: 'Invalid or expired token' });
    }
    
    // Attach user to request object
    req.user = user;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(401).json({ error: 'Authentication failed' });
  }
};

// Configure multer for temporary file storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = './uploads';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + '-' + file.originalname);
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 50 * 1024 * 1024 // 50MB limit
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// File upload endpoint (protected)
app.post('/api/upload', verifyAuth, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file provided' });
    }

    const file = req.file;
    const userId = req.user.id;
    const userEmail = req.user.email;
    
    console.log('📤 Uploading file:', file.originalname, 'Size:', file.size, 'bytes');
    console.log('👤 User:', userEmail);
    
    const fileBuffer = fs.readFileSync(file.path);
    
    // Generate a unique filename with user folder structure
    const timestamp = Date.now();
    const fileName = `${userId}/${timestamp}-${file.originalname}`;
    
    console.log('📦 Uploading to bucket:', supabaseBucket, 'Path:', fileName);
    
    // Upload to Supabase Storage
    const { data, error } = await supabase.storage
      .from(supabaseBucket)
      .upload(fileName, fileBuffer, {
        contentType: file.mimetype,
        cacheControl: '3600',
        upsert: false
      });

    // Clean up temporary file
    fs.unlinkSync(file.path);

    if (error) {
      console.error('❌ Supabase upload error:', error);
      console.error('Error details:', JSON.stringify(error, null, 2));
      return res.status(500).json({ 
        error: 'Failed to upload file to storage',
        details: error.message,
        hint: 'Check that the bucket exists and you have the correct permissions'
      });
    }

    console.log('✅ File uploaded successfully:', fileName);

    // Get public URL
    const { data: publicData } = supabase.storage
      .from(supabaseBucket)
      .getPublicUrl(fileName);

    res.json({
      success: true,
      message: 'File uploaded successfully',
      file: {
        name: file.originalname,
        size: file.size,
        type: file.mimetype,
        path: data.path,
        url: publicData.publicUrl
      }
    });

  } catch (error) {
    console.error('Upload error:', error);
    
    // Clean up temporary file if it exists
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Get list of uploaded files (protected)
app.get('/api/files', verifyAuth, async (req, res) => {
  try {
    const userId = req.user.id;
    
    // List files only for the authenticated user
    const { data, error } = await supabase.storage
      .from(supabaseBucket)
      .list(userId, {
        limit: 100,
        sortBy: { column: 'created_at', order: 'desc' }
      });

    if (error) {
      throw error;
    }

    const filesWithUrls = data.map(file => {
      const { data: publicData } = supabase.storage
        .from(supabaseBucket)
        .getPublicUrl(file.name);
      
      return {
        name: file.name,
        size: file.metadata?.size,
        createdAt: file.created_at,
        url: publicData.publicUrl
      };
    });

    res.json({ files: filesWithUrls });

  } catch (error) {
    console.error('Error fetching files:', error);
    res.status(500).json({ 
      error: 'Failed to fetch files',
      details: error.message 
    });
  }
});

// Serve static files from the React app (for production)
// Important: Place AFTER API routes so API takes precedence
const clientBuildPath = join(__dirname, '../client/dist');
if (fs.existsSync(clientBuildPath)) {
  app.use(express.static(clientBuildPath));
  console.log('Serving static files from:', clientBuildPath);
}

// Catch-all handler: serve index.html for any route not matched above (for React Router)
app.get('*', (req, res) => {
  const indexPath = join(__dirname, '../client/dist/index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.status(404).json({ 
      error: 'Frontend not built. Run "npm run build" in the client directory.' 
    });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`Supabase URL: ${supabaseUrl}`);
  console.log(`Supabase Bucket: ${supabaseBucket}`);
});

