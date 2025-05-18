import SwiftUI

struct EmptyChatListView : View {
    
    var action: () -> Void
    
    var body: some View {
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
            
            Button(action: action) {
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
    }
}
