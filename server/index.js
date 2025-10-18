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
const supabaseUrl = process.env.SUPABASE_URL || 'https://kylvaxbcvovxjeutrcds.supabase.co';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY || 'placeholder_key';
const supabaseBucket = process.env.SUPABASE_BUCKET || 'uploads';

if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_KEY) {
  console.warn('⚠️  Using placeholder Supabase configuration for local development');
  console.warn('⚠️  Set SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables for production');
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

// Dodo Payments checkout endpoint (protected)
app.post('/api/create-checkout', verifyAuth, async (req, res) => {
  try {
    const user = req.user;
    const dodoApiKey = process.env.DODO_PAYMENTS_API_KEY;
    const productId = process.env.DODO_PRODUCT_ID;

    if (!dodoApiKey || !productId) {
      console.error('Missing DODO_PAYMENTS_API_KEY or DODO_PRODUCT_ID');
      return res.status(500).json({ 
        error: 'Payment system not configured',
        details: 'Contact administrator'
      });
    }

    console.log('🛒 Creating checkout session for user:', user.email);

    // Create checkout session with Dodo Payments
    const response = await fetch('https://test.dodopayments.com/checkouts', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${dodoApiKey}`
      },
      body: JSON.stringify({
        product_cart: [
          {
            product_id: productId,
            quantity: 1
          }
        ],
        customer: {
          email: user.email,
          name: user.user_metadata?.username || user.email.split('@')[0]
        },
        return_url: `${process.env.APP_URL || 'http://localhost:3001'}/payment-success`,
        metadata: {
          user_id: user.id,
          user_email: user.email,
          timestamp: new Date().toISOString()
        }
      })
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      console.error('❌ Dodo Payments API error:', response.status, errorData);
      return res.status(response.status).json({
        error: 'Failed to create checkout session',
        details: errorData.message || 'Payment service error'
      });
    }

    const session = await response.json();
    
    console.log('✅ Checkout session created:', session.session_id);
    
    res.json({
      success: true,
      checkout_url: session.checkout_url,
      session_id: session.session_id
    });

  } catch (error) {
    console.error('💥 Checkout creation error:', error);
    res.status(500).json({
      error: 'Internal server error',
      details: error.message
    });
  }
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
      // Construct the full path: userId/filename
      const fullPath = `${userId}/${file.name}`;
      const { data: publicData } = supabase.storage
        .from(supabaseBucket)
        .getPublicUrl(fullPath);
      
      return {
        name: fullPath, // Store the full path for consistency
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

