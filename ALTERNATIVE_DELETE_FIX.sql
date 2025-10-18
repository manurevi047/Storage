-- Alternative Fix for File Deletion Issues (No Owner Permissions Required)
-- Run this in Supabase SQL Editor

-- 1. Check current RLS status
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 2. Check existing policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 3. Drop existing restrictive policies (if any)
DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;
DROP POLICY IF EXISTS "Allow all uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow all downloads" ON storage.objects;
DROP POLICY IF EXISTS "Allow all deletes" ON storage.objects;
DROP POLICY IF EXISTS "Allow all updates" ON storage.objects;

-- 4. Create permissive policies for all operations
CREATE POLICY "Allow all operations" ON storage.objects
    FOR ALL USING (true) WITH CHECK (true);

-- 5. Verify the policies were created
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 6. Check if uploads bucket exists
SELECT id, name, public FROM storage.buckets WHERE name = 'uploads';

-- 7. Create uploads bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'uploads', 
    'uploads', 
    true, 
    52428800, -- 50MB limit
    ARRAY['image/*', 'video/*', 'application/pdf', 'text/*']
)
ON CONFLICT (id) DO NOTHING;
