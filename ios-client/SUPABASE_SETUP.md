# Supabase Setup Guide for iOS Client

## 🚨 **IMPORTANT: You need to run these SQL commands in your Supabase project!**

The file upload is failing because the storage bucket and policies aren't set up. Follow these steps:

### Step 1: Go to Supabase Dashboard
1. Open your Supabase project dashboard
2. Go to **SQL Editor** (in the left sidebar)
3. Click **"New Query"**

### Step 2: Run the Database Setup Commands
Copy and paste the entire contents of `database_schema.sql` into the SQL editor and run it.

**OR** run these commands one by one:

```sql
-- Create storage bucket for file uploads
INSERT INTO storage.buckets (id, name, public)
VALUES ('uploads', 'uploads', true)
ON CONFLICT (id) DO NOTHING;

-- Create storage policies for file uploads
CREATE POLICY "Users can upload their own files" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'uploads' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view their own files" ON storage.objects
    FOR SELECT USING (bucket_id = 'uploads' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own files" ON storage.objects
    FOR DELETE USING (bucket_id = 'uploads' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### Step 3: Verify Setup
After running the SQL commands:
1. Go to **Storage** in your Supabase dashboard
2. You should see an "uploads" bucket
3. The bucket should have the policies we created

### Step 4: Test Upload
1. Run your iOS app
2. Try uploading a file
3. Check the Xcode console for detailed debug logs
4. The logs will show exactly what's happening

## 🔍 **Debug Information**

The app now includes detailed logging. When you try to upload a file, check the Xcode console for:

- `📦 Available buckets: [...]` - Shows what storage buckets exist
- `✅ Uploads bucket found` - Confirms the bucket exists
- `❌ Uploads bucket not found` - Means you need to run the SQL commands
- `❌ Upload failed: [error]` - Shows the specific error

## 🛠️ **Common Issues**

1. **"Storage bucket 'uploads' not found"**
   - **Solution**: Run the SQL commands above

2. **"Permission denied" or "Policy violation"**
   - **Solution**: Make sure the storage policies were created correctly

3. **"Authentication failed"**
   - **Solution**: Make sure you're signed in to the app

4. **"Network error"**
   - **Solution**: Check your internet connection and Supabase URL/API key

## 📱 **Next Steps**

1. Run the SQL commands in Supabase
2. Test the upload again
3. Check the console logs for detailed information
4. If it still fails, share the console output with me
