import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings Screen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Spacer()

            Text("More settings can go here...")
                .font(.title3)
                .foregroundColor(.gray)

            Spacer()
        }
        .navigationTitle("Settings")
    }
}
