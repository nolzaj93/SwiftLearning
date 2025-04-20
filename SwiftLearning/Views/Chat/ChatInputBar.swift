import SwiftUI

struct ChatInputBar: View {
    @Binding var inputText: String
    var onSend: () -> Void
    
    @FocusState private var isFocused: Bool // <-- New: to control keyboard

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Type a message...", text: $inputText, axis: .vertical)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(20)
                .focused($isFocused)
                .submitLabel(.send) // shows "Send" instead of "Return"
                .onSubmit {
                    send()
                }
            
            Button(action: send) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: -2)
    }
    
    private func send() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        onSend()
        inputText = ""
        isFocused = false // <-- Hide the keyboard after send
    }
}
