//
//  HeaderView.swift
//  Musicality
//
//  Created by Elle Lewis on 3/8/24.
//  Copyright © 2024 Later Creative. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack {
            Text("Explore")
                .font(.largeTitle)
                .fontWeight(.light)
            HStack(spacing: 24) {
                Button(action: {}, label: {
                    Text("New")
                })
                .buttonStyle(SquareButtonStyle())
                
                Button(action: {}, label: {
                    Text("Top Charts")
                })
                .buttonStyle(SquareButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 126)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HeaderView()
}
