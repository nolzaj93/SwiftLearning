import Foundation
import SwiftData

@Model
class Message : CustomDebugStringConvertible {
    @Attribute(.unique) var id: UUID
    var role: Role
    var content: String
    @Relationship var chat: Chat?
    @Relationship(inverse: .none) var nextMessage: Message?
    @Attribute var isErrorMessage: Bool = false
    
    enum Role: String, Codable {
        case user, assistant, note
    }

    var debugDescription: String {
        let nextMessageId = nextMessage?.id.uuidString ?? "nil"
        return "Message(id: \(id), role: \(role.rawValue), content: \"\(content)\", nextMessageid: \(nextMessageId))"
    }
    
    init(id: UUID = UUID(), role: Role, content: String, chat: Chat, nextMessage: Message? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.chat = chat
        self.nextMessage = nextMessage
        print(debugDescription)
    }
}

