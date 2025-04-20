import SwiftUI
import SwiftData

struct ChatListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Chat.id) private var chats: [Chat]
    
    @State private var newChat: Chat? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(chats, id: \.id) { chat in
                    NavigationLink(destination: ChatView(chatId: chat.id)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chat.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .padding(.vertical, 4)
                    )
                }
                .onDelete(perform: deleteChats)
            }
            .listStyle(.plain)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("SwiftLearning")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let chat = Chat(title: "New Chat")
                        context.insert(chat)
                        do {
                            try context.save()
                            newChat = chat
                        } catch {
                            print("❌ Error saving context: \(error)")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(item: $newChat) { chat in
                ChatView(chatId: chat.id)
            }
        }
    }
    
    private func deleteChats(at offsets: IndexSet) {
        for index in offsets {
            let chat = chats[index]
            context.delete(chat)
        }
        
        do {
            try context.save()
        } catch {
            print("❌ Error deleting chats: \(error)")
        }
    }
}
