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
        ZStack{
            VStack {
                HeaderView(
                    title: "Explore",
                    buttons: [
                        HeaderButton(title: "New", action: {}),
                        HeaderButton(title: "Top Charts", action: {})
                    ])
                Spacer()
            }
    
            Text("Hello, World!")
            
        }
    }
}

#Preview {
    ExploreView()
}
