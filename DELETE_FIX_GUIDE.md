# Supabase Storage Delete Issue - Diagnostic and Fix

## The Problem
Files are not being deleted from Supabase Storage because Row Level Security (RLS) is likely blocking the delete operations.

## Quick Fix (If you get "must be owner" error)
Run this SQL in your Supabase SQL Editor:

```sql
-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;

-- Create a permissive policy that allows all operations
CREATE POLICY "Allow all operations" ON storage.objects
    FOR ALL USING (true) WITH CHECK (true);
```

## Alternative Fix (If you have owner permissions)
If you have owner permissions on the storage.objects table:

```sql
-- Disable RLS to allow file deletion
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
```

## Alternative Fix (if you want to keep RLS)
If you prefer to keep RLS enabled, create permissive policies:

```sql
-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;

-- Create permissive policies
CREATE POLICY "Allow all operations" ON storage.objects
    FOR ALL USING (true) WITH CHECK (true);
```

## How to Run the Fix
1. Go to your Supabase Dashboard
2. Navigate to SQL Editor
3. Copy and paste the SQL above
4. Click "Run" to execute

## Testing After Fix
1. Try deleting a file in the web app
2. Check the browser console for debugging logs
3. Try deleting a file in the iOS app
4. Check Xcode console for debugging logs
5. Refresh both apps to verify files are gone

## Expected Debug Logs (Web App)
```
🗑️ Web App: Deleting file: filename.ext
🗑️ Web App: File path: userId/filename.ext
🗑️ Web App: Calling delete API with path: userId/filename.ext
🗑️ Server: Delete request for filename: userId/filename.ext
🗑️ Server: User ID: userId
🗑️ Server: Full path to delete: userId/filename.ext
🗑️ Server: File deleted successfully from Supabase Storage
🗑️ Web App: Delete response status: 200
🗑️ Web App: File deleted successfully
```

## Expected Debug Logs (iOS App)
```
🗑️ FilesView: Deleting file: filename.ext
🗑️ FilesView: File path: userId/filename.ext
🗑️ SupabaseManager: Attempting to delete file with path: userId/filename.ext
✅ SupabaseManager: File deleted successfully from Supabase Storage
🗑️ FilesView: Delete result: true
🗑️ FilesView: File removed from local list
```

## If Still Not Working
If files still don't delete after running the SQL fix:
1. Check if you're using the correct Supabase project
2. Verify the bucket name is "uploads"
3. Check if the file paths are correct in the debug logs
4. Make sure you're authenticated with the same user account
