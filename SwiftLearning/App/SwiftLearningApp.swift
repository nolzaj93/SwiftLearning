//
//  SwiftLearningApp.swift
//  SwiftLearning
//
//  Created by Austin Nolz on 4/10/25.
//

import SwiftUI
import SwiftData

@main
struct SwiftLearningApp: App {
    //Global objects
    @StateObject private var keyboardObserver = KeyboardObserver()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    //Data Model Schema
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Chat.self,
            Message.self
        ])
        let modelConfiguration = ModelConfiguration(
                                    schema: schema,
                                    isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(keyboardObserver)
        .environmentObject(networkMonitor)
    }
}
