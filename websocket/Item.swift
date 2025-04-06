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
    var message: String
    
    init(_ timestamp: Date, _ message: String) {
        self.timestamp = timestamp
        self.message = message
    }
}

