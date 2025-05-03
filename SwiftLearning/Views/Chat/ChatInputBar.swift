import SwiftUI

struct ChatInputBar: View {
    @Binding var inputText: String
    var onSend: () -> Void
    
    @FocusState private var isFocused: Bool
    
    @State private var lastCheckTime: Date? = nil
    @State private var isCheckingInternet: Bool = false
    
    @State var isSendDisabled: Bool = true

    var body: some View {
        
        VStack {
//            if isFocused {
//                Button(action: {
//                    isFocused = false
//                }) {
//                    Text("Done")
//                        .foregroundColor(.accentColor) // Text color
//                        .padding(12)
//                        // Transparent background
//                        .cornerRadius(15)
//                }
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                .background(Color.secondary) 
//
//            }
//            if(!NetworkMonitor.shared.isInternetReachable) {
//                    InternetErrorView()
//                }
            HStack(alignment: .bottom) {
                TextField("Type a message...", text: $inputText, axis: .vertical)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    .focused($isFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        send()
                    }
                    .onChange(of: inputText) {
                        //checkInternet()
                        updateSendButtonState()
                    }
                
                    Button(action: send) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Color.primary)
                            .padding(10)
                            .background(Color.secondary)
                            .clipShape(Circle())
                    }
                    .disabled(isSendDisabled)
                    .opacity(isSendDisabled ? 0.5 : 1.0)
                
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .background(Color.clear)
        
    }
    
    private func send() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        onSend()
        inputText = ""
        isFocused = false // <-- Hide the keyboard after send
    }
    
    private func checkInternet() {
        
        let now = Date()
                
        // Check if 5 seconds have passed since the last check
        if let lastCheck = lastCheckTime, now.timeIntervalSince(lastCheck) < 5 {
            // If less than 5 seconds, do nothing
            return
        }

        // Update the last check time
        lastCheckTime = now
        
        Task {
            if !isCheckingInternet {
                isCheckingInternet.toggle()
                let isInternetReachable = await NetworkMonitor.shared.checkConnection()
                DispatchQueue.main.async {
                    self.isCheckingInternet = false
                    print(isInternetReachable ? "Internet OK 🚀" : "Internet failed 🔥")
                }
            }
        }
    }
    
    private func updateSendButtonState() {
        isSendDisabled = !NetworkMonitor.shared.isInternetReachable || inputText.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
