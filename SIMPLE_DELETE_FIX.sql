-- Simple Fix for File Deletion (No Owner Permissions Required)
-- Run this in Supabase SQL Editor

-- Drop any existing restrictive policies
DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;

-- Create a permissive policy that allows all operations
CREATE POLICY "Allow all operations" ON storage.objects
    FOR ALL USING (true) WITH CHECK (true);

-- Verify the policy was created
SELECT policyname, cmd FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';
