-- Alternative Storage Fix - No Table Ownership Required
-- Run this in your Supabase SQL Editor

-- 1. First, let's check what we can access
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 2. Check existing storage policies
SELECT policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 3. Check if uploads bucket exists and create if needed
INSERT INTO storage.buckets (id, name, public)
VALUES ('uploads', 'uploads', true)
ON CONFLICT (id) DO NOTHING;

-- 4. Try to create permissive policies (this should work even without table ownership)
-- Drop existing policies first
DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own files" ON storage.objects;

-- Create new permissive policies
CREATE POLICY "Allow all uploads" ON storage.objects
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all downloads" ON storage.objects
    FOR SELECT USING (true);

CREATE POLICY "Allow all deletes" ON storage.objects
    FOR DELETE USING (true);

CREATE POLICY "Allow all updates" ON storage.objects
    FOR UPDATE USING (true);

-- 5. Verify the policies were created
SELECT policyname, permissive, cmd
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';
