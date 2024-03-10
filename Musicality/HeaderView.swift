//
//  HeaderView.swift
//  Musicality
//
//  Created by Elle Lewis on 3/8/24.
//  Copyright © 2024 Later Creative. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    var buttons: [SquareButton] = []

    var body: some View {
        VStack(spacing: 10) {
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
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 126)
        .background(Color(.background))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HeaderView(title: "Explore", buttons: [SquareButton(title: "New", action: {}), SquareButton(title: "Top Charts", action: {})])
}
