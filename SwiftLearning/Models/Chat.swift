import Foundation
import SwiftData

@Model
class Chat {
    @Attribute(.unique) var id: UUID
    var title: String
    @Relationship(deleteRule: .cascade, inverse: \Message.chat) var messages: [Message]
    @Relationship(inverse: .none) var firstMessage: Message?

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.messages = []
    }
}
