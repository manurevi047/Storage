import Foundation
import Supabase

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase: SupabaseClient
    
    private init() {
        // Using ANON key for proper user authentication
        let supabaseURL = URL(string: "https://kylvaxbcvovxjeutrcds.supabase.co")!
        // Using ANON key for proper user authentication (not service key)
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5bHZheGJjdm92eGpldXRyY2RzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyMzI2NTgsImV4cCI6MjA3NTgwODY1OH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8" // Replace with your ANON key from Supabase Dashboard > Settings > API
        
        self.supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    func checkAuthStatus() {
        Task {
            do {
                let session = try await supabase.auth.session
                await MainActor.run {
                    self.currentUser = session.user
                    self.isAuthenticated = session.user != nil
                }
            } catch {
                await MainActor.run {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            }
        }
    }
    
    func signUp(email: String, password: String, username: String) async -> Bool {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["username": .string(username)]
            )
            
            await MainActor.run {
                self.isLoading = false
                self.currentUser = response.user
                self.isAuthenticated = response.user != nil
            }
            return true
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func signIn(email: String, password: String) async -> Bool {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            await MainActor.run {
                self.isLoading = false
                self.currentUser = response.user
                self.isAuthenticated = true
            }
            return true
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Notes CRUD Operations
    
    func createNote(title: String, content: String) async -> Note? {
        guard let user = currentUser else { return nil }
        
        do {
            let note = Note(
                id: UUID().uuidString,
                title: title,
                content: content,
                userId: user.id.uuidString,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            let response: Note = try await supabase
                .from("notes")
                .insert(note)
                .select()
                .single()
                .execute()
                .value
            
            return response
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return nil
        }
    }
    
    func fetchNotes() async -> [Note] {
        guard let user = currentUser else { return [] }
        
        do {
            let response: [Note] = try await supabase
                .from("notes")
                .select()
                .eq("user_id", value: user.id.uuidString)
                .order("updated_at", ascending: false)
                .execute()
                .value
            
            return response
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return []
        }
    }
    
    func updateNote(_ note: Note) async -> Note? {
        do {
            let updatedNote = Note(
                id: note.id,
                title: note.title,
                content: note.content,
                userId: note.userId,
                createdAt: note.createdAt,
                updatedAt: Date()
            )
            
            let response: Note = try await supabase
                .from("notes")
                .update(updatedNote)
                .eq("id", value: note.id)
                .select()
                .single()
                .execute()
                .value
            
            return response
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return nil
        }
    }
    
    func deleteNote(id: String) async -> Bool {
        do {
            try await supabase
                .from("notes")
                .delete()
                .eq("id", value: id)
                .execute()
            
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Helper Functions
    
    private func getMimeType(for fileName: String) -> String {
        let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()
        
        switch fileExtension {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "bmp":
            return "image/bmp"
        case "webp":
            return "image/webp"
        case "svg":
            return "image/svg+xml"
        case "mp4":
            return "video/mp4"
        case "mov":
            return "video/quicktime"
        case "avi":
            return "video/x-msvideo"
        case "mkv":
            return "video/x-matroska"
        case "wmv":
            return "video/x-ms-wmv"
        case "flv":
            return "video/x-flv"
        case "webm":
            return "video/webm"
        case "mp3":
            return "audio/mpeg"
        case "wav":
            return "audio/wav"
        case "aac":
            return "audio/aac"
        case "flac":
            return "audio/flac"
        case "ogg":
            return "audio/ogg"
        case "m4a":
            return "audio/mp4"
        case "pdf":
            return "application/pdf"
        case "txt":
            return "text/plain"
        case "md":
            return "text/markdown"
        case "rtf":
            return "application/rtf"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "ppt":
            return "application/vnd.ms-powerpoint"
        case "pptx":
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "zip":
            return "application/zip"
        case "rar":
            return "application/x-rar-compressed"
        case "7z":
            return "application/x-7z-compressed"
        case "tar":
            return "application/x-tar"
        case "gz":
            return "application/gzip"
        default:
            return "application/octet-stream"
        }
    }
    
    // MARK: - Diagnostic Functions
    
    func testSupabaseConnection() async -> Bool {
        do {
            print("🔍 Testing Supabase connection...")
            print("🌐 Supabase URL: https://kylvaxbcvovxjeutrcds.supabase.co")
            print("🔑 Using ANON key for proper user authentication")
            
            // Test basic connection by checking auth status
            print("⏱️ Testing authentication...")
            
            let session = try await supabase.auth.session
            if session.user != nil {
                print("✅ Supabase connection successful!")
                print("👤 Authenticated user: \(session.user.email ?? "unknown")")
                print("🆔 User ID: \(session.user.id.uuidString)")
                return true
            } else {
                print("⚠️ No authenticated user - please sign in first")
                return false
            }
            
        } catch {
            print("❌ Supabase connection failed: \(error)")
            print("❌ Error details: \(error)")
            return false
        }
    }
    
    func uploadFile(data: Data, fileName: String) async -> FileItem? {
        // Ensure user is authenticated
        guard let user = currentUser else {
            await MainActor.run {
                self.errorMessage = "User must be authenticated to upload files"
            }
            return nil
        }
        
        do {
            let timestamp = Int(Date().timeIntervalSince1970)
            // Use same path structure as web app: userId/timestamp-filename
            let path = "\(user.id.uuidString)/\(timestamp)-\(fileName)"
            
            print("📤 Uploading file: \(fileName) to path: \(path)")
            print("📊 File size: \(data.count) bytes")
            print("👤 User: \(user.email ?? "unknown")")
            print("🆔 User ID: \(user.id.uuidString)")
            
            // Upload to Supabase Storage with proper user authentication
            let response = try await supabase.storage
                .from("uploads")
                .upload(path, data: data, options: FileOptions(
                    cacheControl: "3600",
                    contentType: getMimeType(for: fileName)
                ))
            
            print("✅ Upload successful: \(response)")
            
            // Get public URL for the uploaded file
            let publicURL = try supabase.storage
                .from("uploads")
                .getPublicURL(path: path)
            
            print("🔗 Public URL: \(publicURL)")
            
            let fileItem = FileItem(
                id: UUID().uuidString,
                name: fileName,
                path: path,
                size: data.count,
                userId: user.id.uuidString, // Use actual user ID
                createdAt: Date(),
                url: publicURL.absoluteString
            )
            
            return fileItem
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                print("❌ File upload failed: \(error.localizedDescription)")
                print("❌ Error type: \(type(of: error))")
            }
            return nil
        }
    }
    
    func fetchFiles() async -> [FileItem] {
        guard let user = currentUser else { return [] }
        
        do {
            // List files only for the authenticated user (same as web app)
            let files = try await supabase.storage
                .from("uploads")
                .list(path: user.id.uuidString)
            
            let fileItems = await withTaskGroup(of: FileItem.self, returning: [FileItem].self) { [self] group in
                for file in files {
                    group.addTask {
                        // Get public URL for each file
                        let publicURL = try? self.supabase.storage
                            .from("uploads")
                            .getPublicURL(path: file.name)
                        
                        return FileItem(
                            id: UUID().uuidString,
                            name: file.name,
                            path: file.name,
                            size: 0, // Size not available in newer Supabase API
                            userId: user.id.uuidString,
                            createdAt: file.createdAt ?? Date(),
                            url: publicURL?.absoluteString ?? ""
                        )
                    }
                }
                
                var items: [FileItem] = []
                for await item in group {
                    items.append(item)
                }
                return items
            }
            
            return fileItems
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return []
        }
    }
    
    func deleteFile(path: String) async -> Bool {
        do {
            try await supabase.storage
                .from("uploads")
                .remove(paths: [path])
            
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Premium Status Check
    
    func checkPremiumStatus() async -> Bool {
        guard let user = currentUser else { return false }
        
        do {
            let response: [String: AnyJSON] = try await supabase
                .from("profiles")
                .select("is_premium")
                .eq("id", value: user.id.uuidString)
                .single()
                .execute()
                .value
            
            if let isPremium = response["is_premium"]?.boolValue {
                return isPremium
            }
            
            return false
        } catch {
            // If profile doesn't exist, user is not premium
            return false
        }
    }
}
