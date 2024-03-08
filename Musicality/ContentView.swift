//
//  ContentView.swift
//  Musicality
//
//  Created by Elle Lewis on 3/7/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            Text("First Tab")
                .tabItem {
                    Label("Explore", image: selection == 0 ? ImageResource.exploreSelectedIcon : ImageResource.exploreIcon)
                }
                .tag(0)

            Text("Second Tab")
                .tabItem {
                    Label("Artists", image: selection == 1 ? ImageResource.micSelectedIcon : ImageResource.micIcon)
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
