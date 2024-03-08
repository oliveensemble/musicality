//
//  MusicalityApp.swift
//  Musicality
//
//  Created by Elle Lewis on 3/7/24.
//  Copyright © 2024 Later Creative LLC. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct MusicalityApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
