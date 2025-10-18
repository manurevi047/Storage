-- Verification Script - Check if File Deletion Fix is Working
-- Run this in Supabase SQL Editor

-- 1. Check if the permissive policy exists
SELECT 
    policyname, 
    cmd, 
    permissive,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'objects' 
  AND schemaname = 'storage' 
  AND policyname = 'Allow all operations';

-- 2. Check RLS status (should still be enabled)
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 3. Check if uploads bucket exists
SELECT id, name, public FROM storage.buckets WHERE name = 'uploads';

-- 4. List recent files (to test deletion)
SELECT 
    name,
    bucket_id,
    created_at,
    metadata
FROM storage.objects 
WHERE bucket_id = 'uploads'
ORDER BY created_at DESC 
LIMIT 5;
