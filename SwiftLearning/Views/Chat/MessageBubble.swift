import SwiftUI
import MarkdownUI

    

struct MessageBubble: View {
    @Bindable var message: Message

    var body: some View {
        HStack(alignment: .top) {
            if message.role == .assistant {
                VStack(alignment: .leading) {
                    Markdown(message.content)
                        .markdownTextStyle {
                            ForegroundColor(.primary)
                        }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .frame(maxWidth: .infinity, alignment: .leading) // full width for assistant
            } else if message.role == .note {
                TextField("Type something...", text: $message.content)
                    .padding(12)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .submitLabel(.done)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
            } else { // user
                Spacer()
                Text(.init(message.content))
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.accentColor.opacity(0.8)) // softer, elegant accent color
                    )
                    .foregroundColor(.white)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
