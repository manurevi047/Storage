-- Fix Storage RLS Issues for Service Key Access
-- Run this in your Supabase SQL Editor

-- Option 1: Disable RLS on storage.objects table (RECOMMENDED for service key usage)
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- Option 2: If you prefer to keep RLS enabled, create permissive policies instead
-- (Uncomment these if you want to keep RLS enabled)

-- -- Drop existing restrictive policies
-- DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;

-- -- Create permissive policies for service key access
-- CREATE POLICY "Allow all uploads" ON storage.objects
--     FOR INSERT WITH CHECK (true);

-- CREATE POLICY "Allow all downloads" ON storage.objects
--     FOR SELECT USING (true);

-- CREATE POLICY "Allow all deletes" ON storage.objects
--     FOR DELETE USING (true);

-- CREATE POLICY "Allow all updates" ON storage.objects
--     FOR UPDATE USING (true);

-- Verify the changes
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';
