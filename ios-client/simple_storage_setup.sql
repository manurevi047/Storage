-- Simple Storage Setup - Minimal Permissions Required
-- Run this in your Supabase SQL Editor

-- 1. Create the uploads bucket (this should work)
INSERT INTO storage.buckets (id, name, public)
VALUES ('uploads', 'uploads', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Create permissive storage policies (this should work without table ownership)
CREATE POLICY "Allow all storage operations" ON storage.objects
    FOR ALL USING (true) WITH CHECK (true);

-- 3. Verify bucket exists
SELECT id, name, public FROM storage.buckets WHERE name = 'uploads';
