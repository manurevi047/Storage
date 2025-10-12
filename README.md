# File Upload App

A modern, full-stack web application for uploading files to Supabase storage. Built with React, Express, and Supabase.

## Features

- 🎨 Beautiful, modern UI with gradient design
- 📤 Upload any file type (images, videos, PDFs, documents, etc.)
- ☁️ Secure cloud storage with Supabase
- 📱 Responsive design for all devices
- 🚀 Fast and efficient file uploads
- 📋 View recently uploaded files
- ✅ Real-time upload status and feedback

## Tech Stack

### Frontend
- **React** - UI library
- **Vite** - Build tool and dev server
- **Modern CSS** - Custom styling with gradients and animations

### Backend
- **Express.js** - Web server framework
- **Multer** - File upload handling
- **Supabase** - Cloud storage solution
- **Node.js** - Runtime environment

## Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- Supabase account and project
- Supabase storage bucket configured

## Installation

1. **Clone or navigate to the project directory:**
   ```bash
   cd file-upload-app
   ```

2. **Install dependencies:**
   ```bash
   npm run install-all
   ```

3. **Set up environment variables:**
   
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=https://kylvaxbcvovxjeutrcds.supabase.co
   SUPABASE_KEY=your_supabase_api_key_here
   SUPABASE_BUCKET=uploads
   PORT=3001
   ```

   **For Render deployment:**
   - Add these environment variables in your Render dashboard
   - The `SUPABASE_KEY` should be your Supabase service role key or anon key

4. **Configure Supabase Storage:**
   - Go to your Supabase project dashboard
   - Navigate to Storage
   - Create a bucket named `uploads` (or use your preferred name)
   - Set appropriate access policies (public or private)

## Development

Run both the frontend and backend concurrently:

```bash
npm run dev
```

This will start:
- Frontend dev server on `http://localhost:3000`
- Backend API server on `http://localhost:3001`

### Run individually:

**Backend only:**
```bash
npm run server
```

**Frontend only:**
```bash
npm run client
```

## Production Build

1. **Build the frontend:**
   ```bash
   npm run build
   ```

2. **The built files will be in `client/dist/`**

## Deployment to Render

### Option 1: Web Service + Static Site

**Backend (Web Service):**
1. Create a new Web Service on Render
2. Connect your repository
3. Set the following:
   - **Build Command:** `npm install`
   - **Start Command:** `npm run server`
   - **Environment Variables:**
     - `SUPABASE_URL`: Your Supabase URL
     - `SUPABASE_KEY`: Your Supabase API key
     - `SUPABASE_BUCKET`: Your bucket name
     - `PORT`: 3001 (or Render's default)

**Frontend (Static Site):**
1. Create a new Static Site on Render
2. Set the following:
   - **Build Command:** `cd client && npm install && npm run build`
   - **Publish Directory:** `client/dist`
3. Update `client/vite.config.js` to use your backend URL

### Option 2: Single Web Service

1. Serve frontend from Express:
   ```javascript
   // Add to server/index.js
   import path from 'path';
   app.use(express.static(path.join(__dirname, '../client/dist')));
   ```
2. Build frontend before deploying
3. Deploy as a single web service

## API Endpoints

### `POST /api/upload`
Upload a file to Supabase storage.

**Request:**
- Method: POST
- Content-Type: multipart/form-data
- Body: file (form field)

**Response:**
```json
{
  "success": true,
  "message": "File uploaded successfully",
  "file": {
    "name": "example.pdf",
    "size": 1024,
    "type": "application/pdf",
    "path": "1234567890-example.pdf",
    "url": "https://...supabase.co/storage/v1/object/public/uploads/..."
  }
}
```

### `GET /api/files`
Get list of uploaded files.

**Response:**
```json
{
  "files": [
    {
      "name": "1234567890-example.pdf",
      "size": 1024,
      "createdAt": "2025-10-12T...",
      "url": "https://...supabase.co/storage/v1/object/public/uploads/..."
    }
  ]
}
```

### `GET /api/health`
Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "message": "Server is running"
}
```

## Project Structure

```
file-upload-app/
├── server/
│   └── index.js          # Express server and API routes
├── client/
│   ├── src/
│   │   ├── App.jsx       # Main React component
│   │   ├── App.css       # Component styles
│   │   ├── index.css     # Global styles
│   │   └── main.jsx      # React entry point
│   ├── public/           # Static assets
│   ├── index.html        # HTML template
│   ├── vite.config.js    # Vite configuration
│   └── package.json      # Frontend dependencies
├── .env                  # Environment variables (create this)
├── .env.example          # Environment variables template
├── .gitignore           # Git ignore rules
├── package.json         # Root dependencies and scripts
└── README.md           # This file
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `SUPABASE_URL` | Your Supabase project URL | `https://xxxxx.supabase.co` |
| `SUPABASE_KEY` | Supabase API key (anon or service role) | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |
| `SUPABASE_BUCKET` | Storage bucket name | `uploads` |
| `PORT` | Backend server port | `3001` |

## Security Considerations

1. **Never commit `.env` file** - It's in `.gitignore`
2. **Use service role key** - For backend operations only
3. **Set up RLS policies** - In Supabase for access control
4. **File size limits** - Currently set to 50MB (configurable in `server/index.js`)
5. **File type validation** - Add validation as needed for your use case

## Customization

### Change file size limit:
Edit `server/index.js`:
```javascript
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024 // 100MB
  }
});
```

### Add file type restrictions:
```javascript
const upload = multer({
  storage: storage,
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'));
    }
  }
});
```

### Customize colors:
Edit `client/src/App.css` and `client/src/index.css` to change the gradient and color scheme.

## Troubleshooting

### "Missing SUPABASE_URL or SUPABASE_KEY"
- Ensure `.env` file exists in the root directory
- Check that environment variables are set correctly

### "Failed to upload file to storage"
- Verify Supabase bucket exists and is accessible
- Check your Supabase API key has proper permissions
- Review Supabase storage policies

### Files not uploading
- Check browser console for errors
- Verify backend server is running
- Check file size is within limits

## License

MIT License - feel free to use this project for any purpose.

## Support

For issues or questions, please open an issue in the repository.

