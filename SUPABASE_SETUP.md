# Supabase Setup Guide

## 🚨 IMPORTANT: Use the Correct URL!

### ❌ WRONG - Storage Endpoint URL:
```
https://kylvaxbcvovxjeutrcds.storage.supabase.co/storage/v1/s3
```
**Don't use this!** This is the S3-compatible storage endpoint, not for the JavaScript client.

### ✅ CORRECT - Project URL:
```
https://kylvaxbcvovxjeutrcds.supabase.co
```
**Use this!** This is your Supabase project URL.

---

## 📝 Step-by-Step Setup

### 1. Get Your Supabase Project URL

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to **Settings** (gear icon) → **API**
4. Copy the **Project URL** (under "Project Configuration")
   - Format: `https://YOUR_PROJECT_REF.supabase.co`

### 2. Get Your Supabase API Key

In the same **API** settings page:

1. Scroll to **Project API keys**
2. Copy the **`service_role`** key (click the eye icon to reveal)
   - Starts with `eyJ...`
   - This is a secret key - keep it secure!

### 3. Create a Storage Bucket

1. In Supabase Dashboard, go to **Storage**
2. Click **"New bucket"**
3. Name it `uploads`
4. Choose bucket settings:
   - **Public bucket**: ✅ Check this if you want files to be publicly accessible
   - **Private bucket**: Leave unchecked (you can set this later with policies)
5. Click **"Create bucket"**

### 4. Set Bucket Policies (Optional)

For public file access:

1. Go to **Storage** → Click your `uploads` bucket
2. Click **"Policies"** tab
3. Add a policy for public access:

```sql
-- Allow public read access
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'uploads' );

-- Allow authenticated uploads (if you add auth later)
CREATE POLICY "Authenticated Uploads"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'uploads' AND auth.role() = 'authenticated' );
```

**OR** simply toggle **"Public bucket"** in bucket settings.

---

## 🔧 Configure Render Environment Variables

In your Render service dashboard:

1. Go to **"Environment"** tab
2. Add these variables:

| Key | Value | Example |
|-----|-------|---------|
| `SUPABASE_URL` | Your project URL | `https://kylvaxbcvovxjeutrcds.supabase.co` |
| `SUPABASE_KEY` | Your service_role key | `eyJhbGci...` (long string) |
| `SUPABASE_BUCKET` | Bucket name | `uploads` |

3. Click **"Save Changes"**
4. Render will auto-redeploy

---

## ✅ Verify Your Configuration

### Test 1: Check Server Logs

After deployment, check Render logs for:

```
✅ Supabase client initialized with URL: https://kylvaxbcvovxjeutrcds.supabase.co
Server running on http://localhost:10000
Supabase URL: https://kylvaxbcvovxjeutrcds.supabase.co
Supabase Bucket: uploads
```

### Test 2: Try Uploading a File

1. Visit your Render URL
2. Click "Choose File"
3. Select a small file
4. Click "Upload"
5. Check the logs for:

```
📤 Uploading file: test.jpg Size: 12345 bytes
📦 Uploading to bucket: uploads
✅ File uploaded successfully: 1234567890-test.jpg
```

### Test 3: Check Supabase Storage

1. Go to Supabase Dashboard → **Storage** → `uploads` bucket
2. You should see your uploaded files

---

## 🆘 Troubleshooting

### Error: "Invalid URL"
**Problem**: Using storage endpoint URL instead of project URL

**Fix**: Update `SUPABASE_URL` to remove `.storage` and `/storage/v1/s3`
- Wrong: `https://xxx.storage.supabase.co/storage/v1/s3`
- Right: `https://xxx.supabase.co`

### Error: "Bucket not found"
**Problem**: The `uploads` bucket doesn't exist

**Fix**:
1. Go to Supabase Dashboard → Storage
2. Create a bucket named `uploads`
3. Redeploy on Render

### Error: "Invalid API key"
**Problem**: Wrong or expired API key

**Fix**:
1. Go to Supabase Dashboard → Settings → API
2. Copy the `service_role` key again
3. Update `SUPABASE_KEY` in Render
4. Save and redeploy

### Error: "Permission denied"
**Problem**: Storage policies are blocking uploads

**Fix**:
1. Make the bucket public, OR
2. Set up proper storage policies (see above)

### Error: "CORS error"
**Problem**: CORS settings blocking requests

**Fix**:
1. Go to Supabase Dashboard → Settings → API
2. Under "CORS Configuration", add your Render URL
3. Or use `*` for development (not recommended for production)

---

## 🔐 Security Best Practices

1. **Never commit your `service_role` key** to GitHub
2. **Use environment variables** on Render
3. **Set up Row Level Security (RLS)** policies for production
4. **Limit bucket access** with proper policies
5. **Consider file size limits** in your policies
6. **Monitor usage** in Supabase Dashboard

---

## 📊 Supabase Storage Limits

### Free Tier:
- **Storage**: 1 GB
- **Bandwidth**: 2 GB per month
- **File uploads**: 50 MB per file

### Pro Tier ($25/month):
- **Storage**: 100 GB
- **Bandwidth**: 200 GB per month
- **File uploads**: 5 GB per file

---

## 🎯 Quick Reference

### Your Configuration:

```env
SUPABASE_URL=https://kylvaxbcvovxjeutrcds.supabase.co
SUPABASE_KEY=your_service_role_key_here
SUPABASE_BUCKET=uploads
```

### Where to Find These:

| Setting | Location in Supabase Dashboard |
|---------|-------------------------------|
| Project URL | Settings → API → Project URL |
| Service Role Key | Settings → API → Project API keys → service_role |
| Bucket Name | Storage → Your bucket name |

---

## ✅ Checklist

Before deploying, verify:

- [ ] Created Supabase project
- [ ] Created `uploads` storage bucket
- [ ] Got Project URL (not storage endpoint)
- [ ] Got `service_role` API key
- [ ] Set bucket to public or configured policies
- [ ] Added environment variables to Render
- [ ] Tested upload functionality

---

Your file upload app should now work perfectly! 🎉

