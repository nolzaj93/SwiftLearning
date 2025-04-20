import Foundation
import SwiftData

@MainActor
class ChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var chatTitle: String = "New Chat"
    
    private let service = StreamingService()
    private var context: ModelContext?
    private var chatId : UUID
    private var chat: Chat? {
        didSet {
            // Update the chat title whenever the chat changes
            chatTitle = chat?.title ?? "New Chat"
        }
    }
    
    init(chatId: UUID) {
        self.chatId = chatId
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

        let userMessage = Message(id: UUID(), role: .user, content: inputText, chat: chat)
        if chat.messages.count > 1 {
            chat.messages[chat.messages.count - 1].nextMessage = userMessage
        }
        
        //need to find the last message if there is one and set it's next message to this
        if chat.firstMessage == nil {
            chat.firstMessage = userMessage
            if chat.title == "New Chat" {
                    chat.title = generateTitle(from: userMessage.content)
                }
//            guard let context else { return }
//            do {
//                    try context.save()
//                    print("✅ Chat saved successfully")
//                } catch {
//                    print("❌ Failed to save chat: \(error)")
//                }
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
            guard let url = URL(string: "http://10.0.0.14:8000/generate") else {
                updateMessage(id: assistantMessageID, content: "❌ Invalid URL")
                return
            }

            do {
                let stream = try await service.streamPOST(to: url, body: ["prompt": prompt, "model":"llama2", "stream": true])

                for try await line in stream {
                    if let data = line.data(using: .utf8) {
                        do {
                            let chunk = try JSONDecoder().decode(StreamChunk.self, from: data)
                            streamingContent += chunk.response
                            updateMessage(id: assistantMessageID, content: streamingContent)
                        } catch {
                            print("Failed to decode: \(error)")
                        }
                    }
                }
            } catch {
                updateMessage(id: assistantMessageID, content: "❌ Error: \(error.localizedDescription)")
            }
        }
    }
    
    //updates the assistant message
    private func updateMessage(id: UUID, content: String) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].content = content
            saveMessage(message: messages[index])
        }
    }
    
    private func saveMessage(message: Message) {
        
        context?.insert(message)
        
        // Persist changes
        do {
            try context?.save()

        } catch {
            print("❌ Error saving context: \(error)")
        }
    }
    
    func loadMessages() {
        guard let context = context else {
            print("⚠️ No ModelContext set in ViewModel")
            return
        }
        
        guard let chat = chat else {
                print("⚠️ No Chat found in ViewModel")
                return
            }
        
        let chatID = chat.id
        do {
            let descriptor = FetchDescriptor<Message>(
                predicate: #Predicate { message in
                    message.chat?.id == chatID
                }
            )
            let fetchedMessages = try context.fetch(descriptor)
            let firstMessage = chat.firstMessage
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
        if trimmed.count > 20 {
            return String(trimmed.prefix(20)) + "..."
        } else {
            return trimmed.isEmpty ? "Untitled Chat" : trimmed
        }
    }
}
