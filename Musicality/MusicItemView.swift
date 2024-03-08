//
//  MusicItemView.swift
//  Musicality
//
//  Created by Elle Lewis on 3/8/24.
//  Copyright © 2024 Later Creative. All rights reserved.
//

import SwiftUI

struct MusicItemView: View {
    let imageURL: URL
    let title: String
    let artistName: String
    let button: SquareButton

    var body: some View {
        HStack(spacing: 12) {
            imageView

            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title3)
                Text(artistName)
                    .font(.body)
                Button(action: button.action, label: {
                    Text(button.title)
                })
                .buttonStyle(SquareButtonStyle())
            }

            Spacer()
        }
        .padding(24)
    }

    var imageView: some View {
        AsyncImage(url: imageURL) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
                    .fill(.gray)
            }
        }
        .frame(width: 120, height: 120)
        .clipped()
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    MusicItemView(imageURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/c/ce/PostalService_cover300dpi.jpg")!, title: "Give Up", artistName: "The Postal Service", button: SquareButton(title: "View", action: {}))
}
