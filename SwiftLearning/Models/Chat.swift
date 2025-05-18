import Foundation
import SwiftData

@Model
class Chat : CustomDebugStringConvertible, Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    @Relationship(deleteRule: .cascade, inverse: \Message.chat) var messages: [Message]
    @Relationship(inverse: .none) var firstMessage: Message?
    var debugDescription: String {
        let firstMessageId = firstMessage?.id.uuidString ?? "nil"
        return "Chat(id: \(id), title: \(title), messages: \(messages), firstMessageId: \(firstMessageId))"
        }

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.messages = []
    }
}
