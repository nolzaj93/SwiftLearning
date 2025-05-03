import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: ChatViewModel
    @EnvironmentObject var keyboardObserver: KeyboardObserver
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var isEditing = false
    @State private var isScrolling : Bool
    
    let chatId: UUID

    init(chatId: UUID) {
        self.chatId = chatId
        _viewModel = StateObject(wrappedValue: ChatViewModel(chatId: chatId, networkMonitor: NetworkMonitor.shared))
        self.isScrolling = false
        
//        Task{
//            self.isInternetReachable = await NetworkMonitor.shared.checkConnection()
//
//        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                            
                            if message.role == .assistant
                                && viewModel.isAwaitingResponse
                                && index == viewModel.messages.count - 1 && networkMonitor.isInternetReachable {
                                LoadingView()
                            } else{
                                MessageBubble(message: message, isEditing: $isEditing)
                                    .padding(.horizontal)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                                    .id(message.id)
                            }
                        }
                    }
                    .contentShape(Rectangle()) // This makes blank areas tappable too
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            hideKeyboard()
                        }
                    )
                    .padding(.top, 16)
                }
                .contentShape(Rectangle())
                .background(Color(.systemGroupedBackground))
                .onChange(of: viewModel.messages.count) {
                    
                    if let lastMessage = viewModel.messages.last {
                        //isScrolling = false
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
//                .onChange(of: viewModel.messages.last?.content) {
//                        if let lastMessage = viewModel.messages.last {
//                            if !isScrolling {
//                                withAnimation(.easeOut(duration: 0.25)) {
//                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
//                                }
//                            }
//                        }
//                }
                .gesture(
                    DragGesture()
                        .onChanged {_ in
                            isScrolling = true
                        }
                )
            }
//            Divider()
//                
//                ChatInputBar(
//                    inputText: $viewModel.inputText,
//                    onSend: viewModel.sendMessage
//                )
//                .padding(.bottom, keyboardObserver.keyboardHeight) // move up when keyboard shows
//                .animation(.easeOut(duration: 0.25), value: keyboardObserver.keyboardHeight)
            
            
        }
        .safeAreaInset(edge: .bottom) {
            
            VStack{
                if(!networkMonitor.isInternetReachable) {
                        InternetErrorView()
                    }
                ChatInputBar(
                    inputText: $viewModel.inputText,
                    onSend: viewModel.sendMessage
                )
            }
        }
        .background(Color(.systemGroupedBackground))
        //.ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle(viewModel.chatTitle)
        .navigationBarTitleDisplayMode(.inline)
        .id(viewModel.chatTitle)
        .onAppear {
            viewModel.setContext(context)
//            Task{
//                await NetworkMonitor.shared.checkConnection()
//
//            }
         }
    }
}
