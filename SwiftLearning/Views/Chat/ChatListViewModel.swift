import SwiftUI
import SwiftData

@MainActor
class ChatListViewModel: ObservableObject {
    //tight coupling, bad for unit testing
    //@Environment(\.modelContext) private var context
    //@Query(sort: \Chat.id) var chats: [Chat]
    
    @Published var chats: [Chat] = []
    @Published var newChat: Chat? = nil
    
    private let chatListContext: ModelContext
    
    init(chatListContext: ModelContext) {
            self.chatListContext = chatListContext
            loadChats()
    }
    
    func loadChats() {
        do {
            // Assuming `Chat` conforms to `Identifiable` and is a SwiftData model
            let descriptor = FetchDescriptor<Chat>(sortBy: [SortDescriptor(\.id)])
            chats = try chatListContext.fetch(descriptor)
            print(chats.count)
        } catch {
            print("❌ Failed to load chats: \(error)")
        }
    }
    
    func createNewChat() {
        let chat = Chat(title: "New Chat")
        chatListContext.insert(chat)
        chats.append(chat)
        do {
            try chatListContext.save()
            newChat = chat
            print(chats.count)
        } catch {
            print("❌ Error saving context: \(error)")
        }
    }
    
    func deleteChats(at offsets: IndexSet) {
        for index in offsets {
            let chat = chats[index]
            
            
            do {
                chatListContext.delete(chat)
                try chatListContext.save()
                chats.remove(at: index)
            } catch {
                print("❌ Error deleting chats: \(error)")
            }
        }
    }
}
