import SwiftUI
import SwiftData

struct ChatListView: View {
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject var chatListViewModel: ChatListViewModel
    
    init(chatListViewModel: ChatListViewModel) {
        _chatListViewModel = StateObject(wrappedValue: chatListViewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                VStack{
                    Group {
                        if chatListViewModel.chats.isEmpty {
                            EmptyChatListView(action: chatListViewModel.createNewChat)
                        } else {
                            List {
                                ForEach(chatListViewModel.chats, id: \.id) { chat in
                                    //
                                    NavigationLink(destination:
                                                    ChatView(viewModel : ChatViewModel(chatId: chat.id, networkMonitor: NetworkMonitor.shared))) {
                                        VStack() {
                                            Text(chat.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                .onDelete(perform: chatListViewModel.deleteChats)
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
                        chatListViewModel.createNewChat()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(.primary)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $chatListViewModel.newChat) { chat in
                ChatView(viewModel : ChatViewModel(chatId: chat.id, networkMonitor: NetworkMonitor.shared))
            }
        }
        .tint(.primary)
    }
    

}

//#Preview("Chat List Debug") {
//    ChatListView(chatListViewModel: ChatListViewModel(chatListContext: context))
//        .modelContainer(for: Chat.self, inMemory: true)
//}

#Preview("Chat List Debug") {
    do {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Chat.self, configurations: configuration)
        let context = ModelContext(container)

        // Optional: Add sample data
        let sampleChat = Chat(title: "Sample Chat")
        context.insert(sampleChat)
        try context.save()

        let viewModel = ChatListViewModel(chatListContext: context)

        return ChatListView(chatListViewModel: viewModel)
            .modelContainer(container)
            .environmentObject(NetworkMonitor.shared)

    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}




