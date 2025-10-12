# Render Setup Guide - Single Unified Deployment

## 🎯 Quick Setup (4 Environment Variables)

In Render dashboard → Your Service → **Environment** tab, add these **4 variables**:

| Variable Name | Value | Where to Find |
|---------------|-------|---------------|
| `SUPABASE_URL` | `https://kylvaxbcvovxjeutrcds.supabase.co` | Supabase → Settings → API → Project URL |
| `SUPABASE_SERVICE_KEY` | Your service_role key | Supabase → Settings → API → service_role (secret) |
| `SUPABASE_ANON_KEY` | Your anon public key | Supabase → Settings → API → anon public |
| `SUPABASE_BUCKET` | `uploads` | Your bucket name in Storage |

---

## 🔧 Build & Deploy Commands

In Render dashboard → Your Service → **Settings**:

### Build Command:
```bash
npm install && cd client && npm install && VITE_SUPABASE_URL=$SUPABASE_URL VITE_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY npm run build && cd ..
```

### Start Command:
```bash
npm start
```

---

## ❓ Why 4 Variables?

### For Backend (Runtime):
- `SUPABASE_URL` - Your project URL
- `SUPABASE_SERVICE_KEY` - Secret key for server operations
- `SUPABASE_BUCKET` - Storage bucket name

### For Frontend (Build Time):
- `SUPABASE_URL` - Passed as `VITE_SUPABASE_URL` during build
- `SUPABASE_ANON_KEY` - Public key, safe to expose in browser

**Important:** The frontend variables are baked into the JavaScript during build time. The backend variables are used when the server runs.

---

## ✅ Step-by-Step Deployment

### 1. Create Render Web Service

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click **New +** → **Web Service**
3. Connect your GitHub: `https://github.com/manurevi047/Storage`

### 2. Configure Service

| Setting | Value |
|---------|-------|
| **Name** | `file-upload-app` (or your choice) |
| **Region** | Choose closest to you |
| **Branch** | `main` |
| **Runtime** | `Node` |
| **Build Command** | `npm install && cd client && npm install && VITE_SUPABASE_URL=$SUPABASE_URL VITE_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY npm run build && cd ..` |
| **Start Command** | `npm start` |

### 3. Add Environment Variables

Click **Advanced** → Add these 4 variables:

```
SUPABASE_URL = https://kylvaxbcvovxjeutrcds.supabase.co
SUPABASE_SERVICE_KEY = eyJhbGc... (your service_role key)
SUPABASE_ANON_KEY = eyJhbGc... (your anon key)
SUPABASE_BUCKET = uploads
```

### 4. Deploy!

Click **Create Web Service** and wait 5-10 minutes for build to complete.

---

## 🔍 Verify Deployment

### Check Logs

In Render → Your Service → **Logs**, look for:

```
✅ Supabase client initialized with URL: https://kylvaxbcvovxjeutrcds.supabase.co
Serving static files from: /opt/render/project/src/client/dist
Server running on http://localhost:10000
```

### Test Your App

1. Visit your Render URL: `https://your-app.onrender.com`
2. You should see the login/signup screen
3. Create an account
4. Upload a file
5. Check Supabase → Storage → `uploads` bucket

---

## 🆘 Troubleshooting

### "Missing SUPABASE_URL or SUPABASE_SERVICE_KEY"

**Fix:** Check that all 4 environment variables are added correctly in Render.

### Build Fails

**Fix:** Make sure the build command includes the `VITE_` prefix:
```bash
VITE_SUPABASE_URL=$SUPABASE_URL VITE_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY npm run build
```

### "Invalid or expired token"

**Fix:** 
1. Check `SUPABASE_SERVICE_KEY` is the **service_role** key (not anon)
2. Check `SUPABASE_ANON_KEY` is the **anon public** key

---

## 📊 What Gets Built

```
┌─────────────────────────────────────────┐
│ RENDER BUILD PROCESS                     │
├─────────────────────────────────────────┤
│ 1. npm install (backend dependencies)   │
│ 2. cd client && npm install             │
│ 3. Set VITE_* from environment          │
│ 4. npm run build (creates client/dist)  │
│ 5. Build complete ✅                     │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│ RENDER START PROCESS                     │
├─────────────────────────────────────────┤
│ • npm start                              │
│ • Express server starts                  │
│ • Reads SUPABASE_URL, SUPABASE_SERVICE   │
│   _KEY, SUPABASE_BUCKET                  │
│ • Serves frontend from client/dist       │
│ • App is LIVE! 🚀                        │
└─────────────────────────────────────────┘
```

---

## 🎉 That's It!

You only need **ONE set of 4 environment variables** in Render. The build command handles passing them to the frontend during build time, and the backend reads them at runtime.

**No separate frontend/backend deployments. Everything runs as one unified service!**

