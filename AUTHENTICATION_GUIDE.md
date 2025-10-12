# Authentication Guide

Your file upload app now includes **user authentication** powered by Supabase Auth! 🔐

## 🎯 Features

- ✅ **User Signup** - Create account with email and password
- ✅ **User Login** - Sign in with existing credentials  
- ✅ **Email Verification** - Optional email confirmation
- ✅ **Protected Uploads** - Only authenticated users can upload files
- ✅ **User-Specific Storage** - Files organized by user ID
- ✅ **JWT Token Authentication** - Secure API requests
- ✅ **Session Management** - Automatic session handling

---

## 🔧 Setup Requirements

### 1. Environment Variables

You need **TWO sets** of environment variables:

#### Backend (.env in root):
```env
SUPABASE_URL=https://kylvaxbcvovxjeutrcds.supabase.co
SUPABASE_KEY=your_service_role_key_here
SUPABASE_BUCKET=uploads
PORT=3001
```

#### Frontend (client/.env):
```env
VITE_SUPABASE_URL=https://kylvaxbcvovxjeutrcds.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_public_key_here
```

### 2. Get Your Keys from Supabase

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Navigate to **Settings** → **API**

You'll find:
- **Project URL**: Copy to both `SUPABASE_URL` and `VITE_SUPABASE_URL`
- **anon public** key: Copy to `VITE_SUPABASE_ANON_KEY`
- **service_role** key: Copy to `SUPABASE_KEY`

---

## 📋 Render Deployment Configuration

Add these environment variables in Render:

| Variable | Value | Where to Find |
|----------|-------|---------------|
| `SUPABASE_URL` | `https://kylvaxbcvovxjeutrcds.supabase.co` | Supabase → Settings → API → Project URL |
| `SUPABASE_KEY` | Your service_role key | Supabase → Settings → API → service_role |
| `SUPABASE_BUCKET` | `uploads` | Your bucket name |
| `VITE_SUPABASE_URL` | Same as SUPABASE_URL | Supabase → Settings → API → Project URL |
| `VITE_SUPABASE_ANON_KEY` | Your anon public key | Supabase → Settings → API → anon public |

**Important:** The `VITE_` prefix is required for Vite to include these in the frontend build!

---

## 🔐 Supabase Auth Configuration

### Enable Email Authentication

By default, Supabase Auth is enabled. To customize:

1. Go to **Authentication** → **Providers**
2. Ensure **Email** provider is enabled
3. Configure settings:
   - **Confirm email**: Toggle on/off (recommended: on for production)
   - **Secure email change**: Recommended on
   - **Email templates**: Customize confirmation emails

### Email Confirmation

**With email confirmation ON:**
- Users receive a confirmation email after signup
- They must click the link to activate their account
- Better security, prevents fake emails

**With email confirmation OFF:**
- Users can sign in immediately after signup
- Faster development/testing
- Less secure

To toggle:
1. **Authentication** → **Settings** → **Email Auth**
2. Toggle **"Enable email confirmations"**

---

## 🎨 How It Works

### User Flow

1. **New User**:
   ```
   Visit App → See Login Screen → Click "Sign Up"
   → Enter email, password, username → Click "Sign Up"
   → (If email confirmation enabled) Check email and confirm
   → Sign in → Upload files
   ```

2. **Returning User**:
   ```
   Visit App → See Login Screen → Enter credentials
   → Click "Sign In" → Upload files
   ```

### Authentication Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   Browser   │─────▶│ Express API  │─────▶│  Supabase   │
│  (React)    │◀─────│  (Backend)   │◀─────│  Storage    │
└─────────────┘      └──────────────┘      └─────────────┘
      │                      │
      │                      │
 Supabase Auth          JWT Verify
 (login/signup)        (protect routes)
      │                      │
      ▼                      ▼
┌─────────────┐      ┌──────────────┐
│ Get JWT     │      │ Validate     │
│ Token       │      │ User Token   │
└─────────────┘      └──────────────┘
```

### File Storage Structure

Files are now organized by user:

```
uploads/
├── user-id-1/
│   ├── 1234567890-file1.pdf
│   └── 1234567891-image.jpg
├── user-id-2/
│   ├── 1234567892-video.mp4
│   └── 1234567893-doc.docx
└── ...
```

This ensures:
- ✅ User privacy - users only see their own files
- ✅ Organization - easy to manage
- ✅ Security - isolated file access

---

## 🔒 Security Features

### 1. JWT Token Verification
Every API request is protected:
```javascript
// Frontend sends token
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

// Backend verifies
verifyAuth middleware → checks token → allows/denies request
```

### 2. Protected Routes
Only authenticated users can:
- ✅ Upload files (`POST /api/upload`)
- ✅ List files (`GET /api/files`)

Public endpoints:
- ✅ Health check (`GET /api/health`)

### 3. User Isolation
- Users only see/access their own files
- Files stored in user-specific folders
- Backend filters requests by user ID

---

## 🧪 Testing Authentication

### Local Development

1. **Start the app**:
   ```bash
   cd client
   # Create .env file with your credentials
   echo "VITE_SUPABASE_URL=https://kylvaxbcvovxjeutrcds.supabase.co" > .env
   echo "VITE_SUPABASE_ANON_KEY=your_anon_key" >> .env
   
   cd ..
   npm run dev
   ```

2. **Test Signup**:
   - Visit http://localhost:3000
   - Click "Sign Up"
   - Enter email, password, username
   - Submit

3. **Check Supabase**:
   - Go to **Authentication** → **Users**
   - You should see your new user

4. **Test Upload**:
   - After login, upload a file
   - Check **Storage** → `uploads` → `{your-user-id}/`
   - File should appear

### Production (Render)

Same flow, just use your Render URL instead of localhost.

---

## 🆘 Troubleshooting

### "Missing Supabase environment variables"

**Problem**: Frontend can't find `VITE_SUPABASE_URL` or `VITE_SUPABASE_ANON_KEY`

**Fix**:
1. Create `client/.env` file locally
2. Add both variables with `VITE_` prefix
3. For Render: Add them in Environment settings
4. Rebuild the app

### "Invalid or expired token"

**Problem**: Backend can't verify JWT

**Causes**:
- User not logged in
- Session expired
- Wrong SUPABASE_KEY in backend

**Fix**:
1. Sign out and sign in again
2. Check backend has correct `service_role` key
3. Verify token is being sent in Authorization header

### "No authorization token provided"

**Problem**: Frontend not sending token

**Fix**:
1. Check browser console for errors
2. Verify user is logged in (check AuthContext)
3. Ensure Authorization header is added to fetch request

### Email confirmation not working

**Problem**: Not receiving confirmation emails

**Fix**:
1. Check Supabase → **Authentication** → **Settings**
2. Verify SMTP settings (for custom email)
3. Check spam folder
4. For development: disable email confirmation

### Users can't sign up

**Problem**: Signup fails with error

**Possible causes**:
- Email already exists
- Password too weak (< 6 characters)
- Email confirmation enabled but email not working

**Fix**:
1. Check browser console for specific error
2. Try different email
3. Use longer password
4. Temporarily disable email confirmation for testing

---

## 📝 Code Examples

### Frontend - Check if user is authenticated

```javascript
import { useAuth } from './contexts/AuthContext'

function MyComponent() {
  const { user, loading } = useAuth()
  
  if (loading) return <div>Loading...</div>
  if (!user) return <div>Please sign in</div>
  
  return <div>Welcome {user.email}!</div>
}
```

### Frontend - Make authenticated request

```javascript
import { supabase } from './lib/supabase'

async function uploadFile(file) {
  const { data: { session } } = await supabase.auth.getSession()
  
  const response = await fetch('/api/upload', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${session.access_token}`
    },
    body: formData
  })
}
```

### Backend - Access user info

```javascript
app.post('/api/upload', verifyAuth, (req, res) => {
  const userId = req.user.id
  const userEmail = req.user.email
  
  // Use user info...
})
```

---

## 🎨 Customization

### Change Password Requirements

Edit `client/src/components/Auth.jsx`:

```javascript
if (password.length < 8) {  // Change from 6 to 8
  setError('Password must be at least 8 characters')
  return
}
```

### Add More User Fields

Update signup in `client/src/components/Auth.jsx`:

```javascript
const { error } = await signUp(email, password, {
  username,
  full_name: fullName,  // Add more fields
  phone: phoneNumber
})
```

### Customize Email Templates

1. Go to Supabase → **Authentication** → **Email Templates**
2. Edit confirmation email, reset password, etc.
3. Use variables: `{{ .Email }}`, `{{ .ConfirmationURL }}`, etc.

---

## 🔄 Future Enhancements

Potential features to add:

- 🔐 Password reset functionality
- 👤 User profile page
- 📧 Email change with confirmation
- 🔗 OAuth providers (Google, GitHub, etc.)
- 👥 User roles and permissions
- 📊 Upload history and analytics
- 🗑️ Delete uploaded files
- 📁 Organize files in folders

---

## 📚 Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [JWT.io](https://jwt.io/) - Decode JWT tokens
- [Supabase Auth UI](https://supabase.com/docs/guides/auth/auth-helpers/auth-ui) - Pre-built components

---

Your app is now secure and ready for production! 🚀

