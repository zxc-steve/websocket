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
            //return try ModelContainer(for: schema, configurations: [modelConfiguration])
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            var context = container.mainContext
            let users = try context.fetch(FetchDescriptor<ChatUser>())
            if  users.count == 0 {
                SampleData.insertSampleData(context)
                try context.save()
            }
            
            return container

        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .task{await WSserver()}
            .modelContainer(sharedModelContainer)

        }
    }
}
