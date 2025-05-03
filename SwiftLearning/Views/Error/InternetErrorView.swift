import SwiftUI

struct InternetErrorView: View {
    var body: some View {
            HStack {
                Image(systemName: "wifi.exclamationmark")
                Text("No Internet Connection")
            }
            .foregroundColor(.white)
            .padding()
            .background(Color(red: 180/255, green: 50/255, blue: 50/255))
            .cornerRadius(12)
            .padding(.horizontal)
            
            
        }
    
}

