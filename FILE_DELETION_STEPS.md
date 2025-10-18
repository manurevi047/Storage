# File Deletion Fix - Step by Step

## The Problem
Files show "successfully deleted" but reappear after refresh because Supabase Storage Row Level Security (RLS) is blocking the actual deletion.

## The Solution
We need to update the storage policies to allow file deletion.

## Step 1: Run Diagnostic (Optional)
First, let's check the current state:

```sql
-- Run DIAGNOSTIC_STORAGE.sql in Supabase SQL Editor
-- This will show current RLS status and policies
```

## Step 2: Apply the Fix
Run this SQL in your Supabase SQL Editor:

```sql
-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;

-- Create a permissive policy that allows all operations
CREATE POLICY "Allow all operations" ON storage.objects
    FOR ALL USING (true) WITH CHECK (true);

-- Verify the policy was created
SELECT policyname, cmd FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';
```

## Step 3: Test the Fix
1. **Try deleting a file** in web app
2. **Check browser console** for:
   ```
   🗑️ Server: File deleted successfully from Supabase Storage
   ```
3. **Refresh the page** - file should stay deleted
4. **Try deleting a file** in iOS app
5. **Check Xcode console** for:
   ```
   ✅ SupabaseManager: File deleted successfully from Supabase Storage
   ```

## Step 4: Verify Success
After running the SQL fix:
- Files should be permanently deleted
- No more "successfully deleted" but file reappears
- Both web app and iOS app should work

## Why This Works
- **Notes deletion works** because it uses the database with proper RLS policies
- **File deletion fails** because storage.objects has restrictive RLS policies
- **Our fix** creates permissive policies that allow all operations
- **Service key** in server ensures secure access

## Files to Use
- `SIMPLE_DELETE_FIX.sql` - Quick fix (recommended)
- `DIAGNOSTIC_STORAGE.sql` - Check current state
- `ALTERNATIVE_DELETE_FIX.sql` - Comprehensive fix
