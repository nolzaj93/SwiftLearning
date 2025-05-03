import Foundation
import SwiftData
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var chatTitle: String
    @Published var isAwaitingResponse: Bool = false
    
    @Published var isInternetReachable: Bool = true {
        didSet {
            print("isConnected changed to: \(isInternetReachable)")
        }
    }
    private var cancellables = Set<AnyCancellable>()
    
    private let service = StreamingService()
    private var context: ModelContext?
    private var chatId : UUID
    private var chat: Chat?
    private let networkMonitor: NetworkMonitor
    
    @MainActor
    init(chatId: UUID, networkMonitor: NetworkMonitor) {
        self.chatId = chatId
        self.chatTitle = ""
        self.networkMonitor = networkMonitor
        
        networkMonitor.$isInternetReachable //access the published variable
                    .receive(on: DispatchQueue.main) //move any updates to the value to the main thread
                    .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
                    .assign(to: &$isInternetReachable) //assign to the local variable isConnected, & means pass the binding
                
//        // Now react to changes, e.g.:
//        networkMonitor.$isConnected
//            .sink { [weak self] connected in
//                if connected {
//                    self?.trySyncPendingMessages()
//                }
//            }
//            .store(in: &cancellables)
    }
    
    func setContext(_ context: ModelContext) {
        self.context = context
        let chatId = self.chatId
        let descriptor = FetchDescriptor<Chat>(
            predicate: #Predicate { $0.id == chatId }
            )
            
            do {
                if let managedChat = try context.fetch(descriptor).first {
                    self.chat = managedChat
                }
            } catch {
                print("Error fetching managed Chat: \(error)")
            }
        
        loadMessages()
    }
    
    struct StreamChunk: Decodable {
        let model: String
        let created_at: String
        let response: String
        let done: Bool
    }
    
    func sendMessage() {
        guard let chat = chat,
                !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // TODO: not the right way to do this
        Task {
            isInternetReachable = await NetworkMonitor.shared.checkConnection()
            if isInternetReachable {
                print("Internet OK 🚀")
            } else {
                print("Internet failed 🔥")
                return
            }
        }
        

        let userMessage = Message(id: UUID(), role: .user, content: inputText, chat: chat)
        if messages.count > 1 {
            messages[messages.count - 1].nextMessage = userMessage
        }
        
        if chat.firstMessage == nil {
            chat.firstMessage = userMessage
            if chat.title == "New Chat" {
                    chat.title = generateTitle(from: userMessage.content)
                //
                }
        }
        
        
        chat.messages.append(userMessage)
        messages.append(userMessage)
        

        let assistantMessageID = UUID()
        var streamingContent = ""
        let placeholder = Message(id: assistantMessageID, role: .assistant, content: "", chat: chat)
        userMessage.nextMessage = placeholder
        saveMessage(message: userMessage)
        messages.append(placeholder)
        
        

        let prompt = inputText
        inputText = ""

        Task {
            
            isAwaitingResponse = true
            
            defer {
                isAwaitingResponse = false
            }
            
            guard let url = URL(string: "http://10.0.0.14:8000/generate") else {
                updateMessage(id: assistantMessageID, content: "❌ Invalid URL")
                return
            }

            do {
                let stream = try await service.streamPOST(to: url, body: ["prompt": prompt, "stream": true])

                for try await line in stream {
                    if let data = line.data(using: .utf8) {
                        do {
                            let chunk = try JSONDecoder().decode(StreamChunk.self, from: data)
                            isAwaitingResponse = false
                            print(chunk.response)
                            streamingContent += chunk.response
                            updateMessage(id: assistantMessageID, content: streamingContent)
                        } catch {
                            print("Failed to decode: \(error)")
                        }
                    }
                }
            } catch {
                //TODO: distinguish if the error is on the end of the API, or if the network connection is bad
                updateMessage(id: assistantMessageID, content: "❌ Error: \(error.localizedDescription)", isError: true)
            }
        }
    }
    
    //updates the assistant message
    private func updateMessage(id: UUID, content: String, isError: Bool = false) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].content = content
            print(isError)
            if(isError){
                messages[index].isErrorMessage = true
                chat?.messages[index].isErrorMessage = true
            }
            saveMessage(message: messages[index], isInsert: false)
        }
    }
    
    private func saveMessage(message: Message, isInsert: Bool = true) {
        if isInsert {
            context?.insert(message)
        }
        
        do {
            try context?.save()

        } catch {
            print("❌ Error saving context: \(error)")
        }
    }
    
    func loadMessages() {
        Task {
            isInternetReachable = await NetworkMonitor.shared.checkConnection()
            if isInternetReachable {
                print("Internet OK 🚀")
            } else {
                print("Internet failed 🔥")
            }
        }
        
        guard let context = context else {
            print("⚠️ No ModelContext set in ViewModel")
            return
        }
        
        guard let chat = chat else {
                print("⚠️ No Chat found in ViewModel")
                return
            }
        chatTitle = chat.title
        let chatID = chat.id
        do {
            let descriptor = FetchDescriptor<Message>(
                predicate: #Predicate { message in
                    message.chat?.id == chatID && !message.isErrorMessage
                }
            )
            let fetchedMessages = try context.fetch(descriptor)
            let firstMessage = chat.firstMessage
            print(chat.firstMessage?.content ?? "nil")
            
            self.messages = orderedMessages(from: fetchedMessages, firstMessage: firstMessage)
        } catch {
            print("Failed to load messages: \(error)")
        }
    }
    
    func orderedMessages(from messages: [Message], firstMessage: Message?) -> [Message] {
        var result = [Message]()
        var lookup: [UUID: Message] = [:]
        
        // Build a lookup dictionary so we can find messages quickly
        for message in messages {
            lookup[message.id] = message
            //print(message.nextMessage?.id ?? "nil")
            print(message.isErrorMessage)
        }
        
        var current = firstMessage
        
        while let message = current {
            result.append(message)
            current = message.nextMessage
        }
        
        return result
    }

    private func generateTitle(from content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 30 {
            return String(trimmed.prefix(30)) + "..."
        } else {
            return trimmed.isEmpty ? "Untitled Chat" : trimmed
        }
    }
}
