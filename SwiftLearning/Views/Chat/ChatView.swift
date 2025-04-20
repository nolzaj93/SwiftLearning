import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: ChatViewModel

    let chatId: UUID

    init(chatId: UUID) {
        self.chatId = chatId
        _viewModel = StateObject(wrappedValue: ChatViewModel(chatId: chatId))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                            MessageBubble(message: message)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.top, 16)
                }
                .background(Color(.systemGroupedBackground))
//                .onChange(of: viewModel.messages.count) {
//                    if let last = viewModel.messages.last {
//                        withAnimation(.easeOut(duration: 0.3)) {
//                            proxy.scrollTo(last.id, anchor: .bottom)
//                        }
//                    }
//                }
            }
            
            Divider()
            
            ChatInputBar(inputText: $viewModel.inputText, onSend: viewModel.sendMessage)
                .padding()
                .background(Color(.systemBackground))
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle(viewModel.chatTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setContext(context)
        }
    }
}
