import Foundation

struct Note: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}