-- Service Key Verification and Alternative Storage Approach
-- Run this in your Supabase SQL Editor

-- 1. Check your current role (should show 'service_role' if service key is working)
SELECT current_user, current_role;

-- 2. Check if you can access storage tables
SELECT COUNT(*) as bucket_count FROM storage.buckets;

-- 3. Try to create bucket with explicit permissions
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('uploads', 'uploads', true, 52428800)
ON CONFLICT (id) DO UPDATE SET 
    public = true,
    file_size_limit = 52428800;

-- 4. Check bucket creation
SELECT id, name, public, file_size_limit, created_at 
FROM storage.buckets 
WHERE name = 'uploads';

-- 5. If policies fail, try this simpler approach
-- (This creates a policy that allows everything)
DO $$
BEGIN
    -- Try to create a very permissive policy
    BEGIN
        CREATE POLICY "Service key access" ON storage.objects
            FOR ALL USING (true) WITH CHECK (true);
    EXCEPTION 
        WHEN duplicate_object THEN
            -- Policy already exists, that's fine
            NULL;
        WHEN insufficient_privilege THEN
            -- Can't create policies, that's also fine
            NULL;
    END;
END $$;
