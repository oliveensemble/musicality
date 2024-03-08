//
//  ExploreView.swift
//  Musicality
//
//  Created by Elle Lewis on 3/8/24.
//  Copyright © 2024 Later Creative. All rights reserved.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        ZStack {
            List {
                Section(header:
                    HeaderView(
                        title: "Explore",
                        buttons: [
                            SquareButton(title: "New", action: {}),
                            SquareButton(title: "Top Charts", action: {})
                        ])
                        .textCase(nil)
                        .foregroundStyle(Color.primary)
                        .padding(0)
                        .listRowInsets(EdgeInsets()),
                    content: {
                        ForEach(1 ..< 20) { _ in
                            MusicItemView(imageURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/c/ce/PostalService_cover300dpi.jpg")!, title: "Give Up", artistName: "The Postal Service", button: SquareButton(title: "View", action: {}))
                        }
                    
                    })
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            
            GeometryReader { reader in
                Color(.background)
                    .frame(height: reader.safeAreaInsets.top, alignment: .top)
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    ExploreView()
}
