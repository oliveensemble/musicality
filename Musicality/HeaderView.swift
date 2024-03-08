//
//  HeaderView.swift
//  Musicality
//
//  Created by Elle Lewis on 3/8/24.
//  Copyright © 2024 Later Creative. All rights reserved.
//

import SwiftUI

struct HeaderButton: Identifiable {
    let id = UUID()
    let title: String
    let action: () -> ()
}

struct HeaderView: View {
    let title: String
    var buttons: [HeaderButton] = []

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.light)
            HStack(spacing: 24) {
                ForEach(buttons) { button in
                    Button(action: button.action, label: {
                        Text(button.title)
                    })
                    .buttonStyle(SquareButtonStyle())
                }
            }
            Divider()
                .padding(.top, 12)
                .shadow(color: .black, radius: 0.5, y: 0.5)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 126)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HeaderView(title: "Explore", buttons: [HeaderButton(title: "New", action: {}), HeaderButton(title: "Top Charts", action: {})])
}
