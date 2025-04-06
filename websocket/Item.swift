//
//  Item.swift
//  websocket
//
//  Created by steve on 2025/4/6.
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
