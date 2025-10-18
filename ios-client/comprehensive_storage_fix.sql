-- Comprehensive Storage Setup Check and Fix
-- Run this in your Supabase SQL Editor to diagnose and fix storage issues

-- 1. Check current RLS status
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled,
    hasindexes,
    hasrules
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

-- 3. Check if uploads bucket exists
SELECT id, name, public, created_at, updated_at
FROM storage.buckets 
WHERE name = 'uploads';

-- 4. Create uploads bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'uploads', 
    'uploads', 
    true, 
    52428800, -- 50MB limit
    ARRAY['image/*', 'video/*', 'application/pdf', 'text/*']
)
ON CONFLICT (id) DO NOTHING;

-- 5. Fix RLS issues (choose one approach)

-- APPROACH A: Disable RLS completely (RECOMMENDED for service key)
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- APPROACH B: Keep RLS but create permissive policies (uncomment if you prefer this)
-- -- Drop all existing policies
-- DO $$ 
-- DECLARE 
--     policy_record RECORD;
-- BEGIN 
--     FOR policy_record IN 
--         SELECT policyname 
--         FROM pg_policies 
--         WHERE tablename = 'objects' AND schemaname = 'storage'
--     LOOP 
--         EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(policy_record.policyname) || ' ON storage.objects';
--     END LOOP; 
-- END $$;

-- -- Create new permissive policies
-- CREATE POLICY "Allow all operations" ON storage.objects
--     FOR ALL USING (true) WITH CHECK (true);

-- 6. Verify the fix
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 7. Test bucket access
SELECT id, name, public FROM storage.buckets WHERE name = 'uploads';
