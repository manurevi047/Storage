-- Diagnostic Script for File Deletion Issues
-- Run this in Supabase SQL Editor to check current state

-- 1. Check current RLS status
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 2. Check existing policies on storage.objects
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

-- 3. Check if uploads bucket exists
SELECT id, name, public FROM storage.buckets WHERE name = 'uploads';

-- 4. Check recent files in storage (last 10)
SELECT 
    name,
    bucket_id,
    created_at,
    updated_at,
    metadata
FROM storage.objects 
WHERE bucket_id = 'uploads'
ORDER BY created_at DESC 
LIMIT 10;
