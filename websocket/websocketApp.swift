//
//  websocketApp.swift
//  websocket
//
//  Created by steve on 2025/4/6.
//

import SwiftUI
import SwiftData

@main
struct websocketApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            //Item.self,
            ChatGroup.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .modelContainer(sharedModelContainer)

        }
    }
}
