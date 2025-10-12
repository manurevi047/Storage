# Render Deployment Guide

## 🚀 Deploy Your File Upload App to Render

Follow these steps to deploy your app as a **single Web Service** on Render.

## Option 1: Deploy via Render Dashboard (Recommended)

### Step 1: Create a Web Service

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository: `https://github.com/manurevi047/Storage`
4. Click **"Connect"**

### Step 2: Configure the Service

Fill in the following settings:

| Setting | Value |
|---------|-------|
| **Name** | `file-upload-app` (or your preferred name) |
| **Region** | Choose closest to you |
| **Branch** | `main` |
| **Root Directory** | Leave empty |
| **Runtime** | `Node` |
| **Build Command** | `npm install && cd client && npm install && npm run build` |
| **Start Command** | `npm run server` |
| **Instance Type** | `Free` (or your choice) |

### Step 3: Add Environment Variables

Click **"Advanced"** and add these environment variables:

| Key | Value |
|-----|-------|
| `SUPABASE_URL` | `https://kylvaxbcvovxjeutrcds.supabase.co` |
| `SUPABASE_KEY` | Your Supabase service_role key |
| `SUPABASE_BUCKET` | `uploads` |
| `NODE_VERSION` | `18` |

### Step 4: Deploy

1. Click **"Create Web Service"**
2. Wait for the build and deployment to complete (5-10 minutes)
3. Your app will be available at: `https://your-app-name.onrender.com`

---

## Option 2: Deploy via render.yaml (Auto-deploy)

We've included a `render.yaml` file in your repository for automated deployments.

### Steps:

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click **"New +"** → **"Blueprint"**
3. Connect your repository: `https://github.com/manurevi047/Storage`
4. Render will detect the `render.yaml` file
5. Add the required environment variables:
   - `SUPABASE_URL`
   - `SUPABASE_KEY`
6. Click **"Apply"**

---

## 🔧 Troubleshooting

### 404 Error / Blank Page

**Cause:** Frontend not built properly

**Fix:**
```bash
# Locally test the build
cd ~/file-upload-app
npm run build
npm run server
# Visit http://localhost:3001
```

If it works locally, redeploy on Render with the correct build command.

### Build Fails on Render

**Check:**
1. Build command is correct: `npm install && cd client && npm install && npm run build`
2. Node version is 18 or higher
3. All dependencies are in `package.json`

### "Missing SUPABASE_URL or SUPABASE_KEY"

**Fix:**
1. Go to your Render service → **"Environment"** tab
2. Add the missing environment variables
3. Save changes (auto-redeploys)

### File Upload Fails

**Check:**
1. Supabase bucket exists (name: `uploads`)
2. `SUPABASE_KEY` is the correct `service_role` key
3. Check Render logs: Service → **"Logs"** tab

### Files Upload but Can't Access URLs

**Fix:**
1. Go to Supabase Dashboard → Storage → `uploads` bucket
2. Click bucket settings → **"Make bucket public"**
3. Or set appropriate access policies

---

## 📊 Verify Deployment

### Test the API Endpoints:

1. **Health Check:**
   ```bash
   curl https://your-app-name.onrender.com/api/health
   ```
   Should return: `{"status":"ok","message":"Server is running"}`

2. **Upload Test:**
   Visit your app URL and try uploading a file

3. **Check Logs:**
   - Go to your Render service
   - Click **"Logs"** tab
   - Look for startup messages

---

## 🔄 Updating Your Deployment

Every time you push to GitHub `main` branch, Render will automatically rebuild and redeploy.

### Manual Redeploy:
1. Go to your Render service
2. Click **"Manual Deploy"** → **"Deploy latest commit"**

---

## 💡 Performance Tips

### Free Tier Considerations:
- Services spin down after 15 minutes of inactivity
- First request after spin-down takes 30-60 seconds
- Upgrade to paid tier for 24/7 uptime

### Optimization:
- Free tier is perfect for testing and low-traffic apps
- For production, consider upgrading to Starter ($7/month) for:
  - Faster builds
  - No spin-down
  - More resources

---

## 🆘 Need Help?

1. **Check Render Logs:**
   - Service → Logs tab
   - Look for error messages

2. **Check Supabase Logs:**
   - Supabase Dashboard → Logs
   - Look for API errors

3. **Local Testing:**
   ```bash
   cd ~/file-upload-app
   npm run build
   npm run server
   ```

---

## 📝 Common Environment Variables

| Variable | Where to Find |
|----------|---------------|
| `SUPABASE_URL` | Supabase Dashboard → Settings → API → Project URL |
| `SUPABASE_KEY` | Supabase Dashboard → Settings → API → `service_role` key |
| `SUPABASE_BUCKET` | The bucket name you created in Storage |

---

Your app should now be live! 🎉

