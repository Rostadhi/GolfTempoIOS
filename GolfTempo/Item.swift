//
//  Item.swift
//  GolfTempo
//
//  Created by rostadhi akbar on 03/07/25.
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
