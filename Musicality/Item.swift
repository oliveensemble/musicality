//
//  Item.swift
//  Musicality
//
//  Created by Elle Lewis on 3/7/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
