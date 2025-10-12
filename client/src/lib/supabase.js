import { createClient } from '@supabase/supabase-js'

// In production (Render), these are set during build
// In development, use .env file
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || import.meta.env.SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || import.meta.env.SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase environment variables')
  console.error('Make sure SUPABASE_URL and SUPABASE_ANON_KEY are set')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

