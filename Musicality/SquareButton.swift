//
//  Button.swift
//  Musicality
//
//  Created by Elle Lewis on 3/8/24.
//  Copyright © 2024 Later Creative. All rights reserved.
//

import Foundation

struct SquareButton: Identifiable {
    let id = UUID()
    let title: String
    let action: () -> ()
}
