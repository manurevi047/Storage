import Foundation

struct FileItem: Identifiable, Codable {
    let id: String
    let name: String
    let path: String
    let size: Int
    let userId: String
    let createdAt: Date
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case path
        case size
        case userId = "user_id"
        case createdAt = "created_at"
        case url
    }
    
    // Computed property to get file type
    var fileType: String {
        let fileExtension = URL(fileURLWithPath: name).pathExtension.lowercased()
        
        switch fileExtension {
        case "jpg", "jpeg", "png", "gif", "bmp", "webp", "svg":
            return "image"
        case "mp4", "mov", "avi", "mkv", "wmv", "flv", "webm":
            return "video"
        case "mp3", "wav", "aac", "flac", "ogg", "m4a":
            return "audio"
        case "pdf":
            return "pdf"
        case "txt", "md", "rtf":
            return "text"
        case "doc", "docx":
            return "document"
        case "xls", "xlsx":
            return "spreadsheet"
        case "ppt", "pptx":
            return "presentation"
        case "zip", "rar", "7z", "tar", "gz":
            return "archive"
        default:
            return "file"
        }
    }
    
    // Computed property to get file icon
    var fileIcon: String {
        switch fileType {
        case "image":
            return "🖼️"
        case "video":
            return "🎥"
        case "audio":
            return "🎵"
        case "pdf":
            return "📄"
        case "text":
            return "📝"
        case "document":
            return "📄"
        case "spreadsheet":
            return "📊"
        case "presentation":
            return "📽️"
        case "archive":
            return "📦"
        default:
            return "📎"
        }
    }
    
    // Computed property to format file size
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}