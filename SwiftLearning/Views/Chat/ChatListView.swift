import SwiftUI
import SwiftData

struct ChatListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Chat.id) private var chats: [Chat]
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var newChat: Chat? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                VStack{
                    Group {
                        if chats.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 10)
                                
                                Text("Ready to Learn iOS Development?")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button(action: createNewChat) {
                                    Text("Start Learning")
                                        .font(.headline)
                                        .foregroundColor(Color.primary)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.secondary)
                                        .cornerRadius(12)
                                        .padding(.horizontal, 40)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List {
                                ForEach(chats, id: \.id) { chat in
                                    NavigationLink(destination: ChatView(chatId: chat.id)) {
                                        VStack() {
                                            Text(chat.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                .onDelete(perform: deleteChats)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            
                            
                        }
                    }
                    if(!networkMonitor.isInternetReachable) {
                        InternetErrorView()
                    }
                }
                
                
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SwiftLearning")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        createNewChat()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(.primary)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $newChat) { chat in
                ChatView(chatId: chat.id)
            }
        }
        .tint(.primary)
    }
    
    private func createNewChat() {
        let chat = Chat(title: "New Chat")
        context.insert(chat)
        do {
            try context.save()
            newChat = chat
        } catch {
            print("❌ Error saving context: \(error)")
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

#Preview("Chat List Debug") {
    ChatListView()
        .modelContainer(for: Chat.self, inMemory: true)
}

