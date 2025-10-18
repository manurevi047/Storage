# File Upload App - iOS Client

A simple iOS client for the File Upload App with Supabase authentication, text notes CRUD operations, file upload/storage, and premium status display.

## Features

- **Authentication**: Username/password authentication via Supabase
- **Text Notes**: Full CRUD operations for text notes
- **File Upload**: Upload and manage files with Supabase Storage
- **Premium Status**: Display user premium/non-premium status from database
- **Modern UI**: SwiftUI-based interface with tab navigation

## Setup Instructions

### 1. Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later
- Supabase account and project

### 2. Database Setup

1. Open your Supabase project dashboard
2. Go to the SQL Editor
3. Run the SQL commands from `database_schema.sql` to create the necessary tables and policies

### 3. Configure Supabase

1. Open `FileUploadApp/Managers/SupabaseManager.swift`
2. Replace the placeholder values with your actual Supabase credentials:

```swift
let supabaseURL = URL(string: "https://YOUR_PROJECT_REF.supabase.co")!
let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
```

### 4. Build and Run

1. Open `FileUploadApp.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project (⌘+R)

## Project Structure

```
FileUploadApp/
├── FileUploadAppApp.swift          # App entry point
├── ContentView.swift               # Main content view with authentication check
├── Views/
│   ├── AuthView.swift              # Login/signup interface
│   ├── NotesView.swift             # Notes list and detail views
│   ├── FilesView.swift             # File upload and management
│   └── ProfileView.swift           # User profile and premium status
├── Models/
│   ├── Note.swift                  # Note data model
│   └── FileItem.swift              # File data model
├── Managers/
│   └── SupabaseManager.swift       # Supabase client and API calls
└── Assets.xcassets/                # App icons and colors
```

## Key Components

### SupabaseManager
- Handles all Supabase authentication and API calls
- Manages user session state
- Provides CRUD operations for notes and files
- Checks premium status from database

### Authentication Flow
- Sign up with email, password, and username
- Sign in with email and password
- Automatic session management
- Sign out functionality

### Notes Management
- Create new notes with title and content
- View list of all user notes
- Edit existing notes inline
- Delete notes with swipe gesture
- Real-time updates

### File Management
- Upload files using PhotosPicker
- Support for images and videos
- File size display
- Delete files with swipe gesture
- Organized by user folders

### Premium Status
- Displays premium/free user status
- Shows crown icon for premium users
- Fetches status from profiles table
- Real-time status updates

## Database Schema

The app uses two main tables:

### notes
- `id`: UUID primary key
- `title`: Note title
- `content`: Note content
- `user_id`: Reference to auth.users
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

### profiles
- `id`: UUID reference to auth.users
- `username`: User's display name
- `is_premium`: Boolean premium status
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

## Security

- Row Level Security (RLS) enabled on all tables
- Users can only access their own data
- Secure file upload with user-specific folders
- JWT-based authentication

## Dependencies

- Supabase Swift SDK (via Swift Package Manager)
- SwiftUI (iOS 17.0+)
- PhotosUI (for file picker)

## Troubleshooting

### Common Issues

1. **Build Errors**: Make sure you're using Xcode 15.0+ and iOS 17.0+
2. **Supabase Connection**: Verify your URL and API key are correct
3. **Database Errors**: Ensure you've run the database schema SQL
4. **File Upload Issues**: Check that the 'uploads' storage bucket exists and has proper policies

### Debug Tips

- Check Xcode console for error messages
- Verify Supabase project settings
- Test database queries in Supabase SQL editor
- Check storage bucket permissions

## Future Enhancements

- Push notifications
- Offline support
- File sharing
- Advanced file management
- Payment integration for premium upgrades
- Dark mode support
- Search functionality

## License

This project is part of the File Upload App ecosystem.
