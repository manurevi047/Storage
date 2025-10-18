import SwiftUI
import PhotosUI

struct FilesView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var files: [FileItem] = []
    @State private var isLoading = false
    @State private var isUploading = false
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading files...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if isUploading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Uploading file...")
                            .font(.headline)
                        Text("Please wait while your file is being uploaded")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if files.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "folder")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No files yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Tap the + button to upload your first file")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(files) { file in
                            FileRowView(file: file) {
                                deleteFile(file)
                            }
                        }
                        .onDelete(perform: deleteFiles)
                    }
                }
            }
            .navigationTitle("Files (\(files.count))")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        loadFiles()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $selectedItem, matching: .any(of: [.images, .videos])) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onChange(of: selectedItem) { _, newValue in
                if let newValue = newValue {
                    uploadFile(item: newValue)
                }
            }
            .onAppear {
                loadFiles()
            }
            .alert("Upload Status", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loadFiles() {
        isLoading = true
        Task {
            let fetchedFiles = await supabaseManager.fetchFiles()
            await MainActor.run {
                self.files = fetchedFiles
                self.isLoading = false
            }
        }
    }
    
    private func uploadFile(item: PhotosPickerItem) {
        isUploading = true
        
        Task {
            do {
                // Try to get the original file information
                if let data = try await item.loadTransferable(type: Data.self) {
                    // Get the original filename if available
                    var fileName = "file_\(Date().timeIntervalSince1970)"
                    
                    // Determine file type from data and add appropriate extension
                    let fileExtension = determineFileExtension(from: data)
                    fileName = "file_\(Date().timeIntervalSince1970).\(fileExtension)"
                    
                    if let file = await supabaseManager.uploadFile(data: data, fileName: fileName) {
                        await MainActor.run {
                            files.insert(file, at: 0)
                            isUploading = false
                            alertMessage = "File uploaded successfully!"
                            showingAlert = true
                        }
                    } else {
                        await MainActor.run {
                            isUploading = false
                            alertMessage = "Failed to upload file. Please try again."
                            showingAlert = true
                        }
                    }
                } else {
                    await MainActor.run {
                        isUploading = false
                        alertMessage = "Could not load file data. Please try again."
                        showingAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    alertMessage = "Upload failed: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    // Helper function to determine file extension from data
    private func determineFileExtension(from data: Data) -> String {
        // Check for common image formats
        if data.starts(with: [0xFF, 0xD8, 0xFF]) {
            return "jpg"
        } else if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            return "png"
        } else if data.starts(with: [0x47, 0x49, 0x46]) {
            return "gif"
        } else if data.starts(with: [0x42, 0x4D]) {
            return "bmp"
        } else if data.starts(with: [0x52, 0x49, 0x46, 0x46]) {
            // Check if it's a WebP image
            if data.count > 12 && data.subdata(in: 8..<12) == Data([0x57, 0x45, 0x42, 0x50]) {
                return "webp"
            }
            return "unknown"
        }
        
        // Check for video formats
        if data.starts(with: [0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70]) {
            return "mp4"
        } else if data.starts(with: [0x00, 0x00, 0x00, 0x14, 0x66, 0x74, 0x79, 0x70]) {
            return "mp4"
        }
        
        // Default to unknown if we can't determine
        return "unknown"
    }
    
    private func deleteFiles(offsets: IndexSet) {
        for index in offsets {
            let file = files[index]
            Task {
                let success = await supabaseManager.deleteFile(path: file.path)
                if success {
                    files.remove(at: index)
                }
            }
        }
    }
    
    private func deleteFile(_ file: FileItem) {
        Task {
            let success = await supabaseManager.deleteFile(path: file.path)
            if success {
                await MainActor.run {
                    files.removeAll { $0.id == file.id }
                }
            }
        }
    }
}

struct FileRowView: View {
    let file: FileItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            // Use emoji icon from FileItem
            Text(file.fileIcon)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(file.fileType.capitalized)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    if file.size > 0 {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(file.formattedSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(file.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 16))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FilesView()
}