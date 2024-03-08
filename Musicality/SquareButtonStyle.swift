//
//  SquareButtonStyle.swift
//  Musicality
//
//  Created by Elle Lewis on 3/8/24.
//  Copyright © 2024 Later Creative. All rights reserved.
//

import SwiftUI

struct SquareButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.light)
            .padding(.vertical, 8)
            .padding(.horizontal)
            .border(.black, width: 2)
    }
}

struct SquareButtonStyleView: View {
    var body: some View {
        Button(action: {}, label: {
            Text("Button")
        })
        .buttonStyle(SquareButtonStyle())
    }
}

#Preview {
    SquareButtonStyleView()
}
