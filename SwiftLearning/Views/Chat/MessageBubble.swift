import SwiftUI
import MarkdownUI

struct MessageBubble: View {
    @Bindable var message: Message
    @Binding var isEditing: Bool

    var body: some View {
        HStack(alignment: .top) {
            if message.role == .assistant {
                VStack(alignment: .leading) {
//                    if isEditing {
//                        TextField("Edit...", text: $message.content, axis: .vertical)
//                            .textFieldStyle(.plain)
//                            .padding(8)
//                            .background(Color(.secondarySystemBackground))
//                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                            .submitLabel(.done)
//                    } else {
                        Markdown(message.content)
                            .markdownTextStyle {
                                ForegroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                    //}
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 120)
                .onTapGesture {
                    isEditing.toggle()
                }
            } else if message.role == .note {
                TextField("Type something...", text: $message.content, axis: .vertical)
                    .padding(12)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .submitLabel(.done)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
            } else { // user
                Spacer()
                VStack(alignment: .trailing) {
//                    if isEditing {
//                        TextField("Edit...", text: $message.content, axis: .vertical)
//                            .textFieldStyle(.plain)
//                            .padding(8)
//                            .background(Color.accentColor.opacity(0.2))
//                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                            .submitLabel(.done)
//                    } else {
                        Text(.init(message.content))
                            .foregroundColor(.white)
                    //}
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.secondary)
                )
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                .onTapGesture {
                    isEditing.toggle()
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
