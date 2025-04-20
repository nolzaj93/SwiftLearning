import Foundation
import SwiftData

@Model
class Message {
    @Attribute(.unique) var id: UUID
    var role: Role
    var content: String
    @Relationship var chat: Chat?
    @Relationship(inverse: .none) var nextMessage: Message?
    
    enum Role: String, Codable {
        case user, assistant, note
    }

    init(id: UUID = UUID(), role: Role, content: String, chat: Chat, nextMessage: Message? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.chat = chat
        self.nextMessage = nextMessage
    }
}

