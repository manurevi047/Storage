# How to Fix "Invalid API Key" Error in iOS App

## The Problem
The iOS app is using a placeholder ANON key instead of your real Supabase ANON key, causing authentication failures.

## Solution: Get Your Real Supabase ANON Key

### Step 1: Access Supabase Dashboard
1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Sign in to your account
3. Select your project: `kylvaxbcvovxjeutrcds`

### Step 2: Get the ANON Key
1. In your project dashboard, go to **Settings** → **API**
2. Look for the **Project API keys** section
3. Copy the **anon public** key (it should start with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

### Step 3: Update iOS App
Replace the placeholder key in `ios-client/FileUploadApp/FileUploadApp/Managers/SupabaseManager.swift`:

**Current (incorrect):**
```swift
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5bHZheGJjdm92eGpldXRyY2RzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyMzI2NTgsImV4cCI6MjA3NTgwODY1OH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8"
```

**Replace with your real ANON key:**
```swift
let supabaseKey = "YOUR_REAL_ANON_KEY_HERE"
```

### Step 4: Test the Fix
1. Save the file in Xcode
2. Build and run the iOS app
3. Try to sign in - it should work now

## Alternative: Use Environment Variables (Recommended)
For better security, you can also set up environment variables in Xcode:

1. In Xcode, select your project
2. Go to **Build Settings** → **User-Defined**
3. Add `SUPABASE_ANON_KEY` with your real ANON key
4. Update the code to use `ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]`

## Important Notes
- The ANON key is safe to use in client applications
- Never use the SERVICE key in client applications
- The ANON key allows users to authenticate and access their own data
- The SERVICE key bypasses all security policies (server-side only)

## Still Having Issues?
If you're still getting errors after updating the key:
1. Make sure you copied the entire ANON key (it's quite long)
2. Check that there are no extra spaces or characters
3. Verify the Supabase URL is correct: `https://kylvaxbcvovxjeutrcds.supabase.co`
4. Check your Supabase project is active and not paused
