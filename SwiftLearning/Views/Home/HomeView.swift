//
//  ContentView.swift
//  SwiftLearning
//
//  Created by Austin Nolz on 4/10/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        ChatListView(chatListViewModel: ChatListViewModel(chatListContext: context))
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Item.self, inMemory: true)
}
