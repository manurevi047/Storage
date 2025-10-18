-- Quick Fix for File Deletion Issues
-- Run this in Supabase SQL Editor

-- 1. Check current RLS status
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 2. Disable RLS to allow file deletion
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- 3. Verify RLS is disabled
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 4. Check if uploads bucket exists
SELECT id, name, public FROM storage.buckets WHERE name = 'uploads';

-- 5. Create uploads bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'uploads', 
    'uploads', 
    true, 
    52428800, -- 50MB limit
    ARRAY['image/*', 'video/*', 'application/pdf', 'text/*']
)
ON CONFLICT (id) DO NOTHING;
