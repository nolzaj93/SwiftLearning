//
//  ContentView.swift
//  SwiftLearning
//
//  Created by Austin Nolz on 4/10/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                Text("SwiftLearning")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                VStack(spacing: 0) {
//                    NavigationLink(destination: ChatView()) {
//                        Text("Start Chat")
//                            .font(.title2)
//                            .frame(maxWidth: .infinity)
//                            .foregroundColor(.blue)
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                            .bold()
//                            
//                    }

                    NavigationLink(destination: SettingsView()) {
                        Text("Settings")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                Spacer()
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Item.self, inMemory: true)
}
