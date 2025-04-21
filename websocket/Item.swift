//
//  Item.swift
//  websocket
//
//  Created by steve on 2025/4/6.
//

import Foundation
import SwiftData

@Model
final class Item  {
    var timestamp: Date
    var message: String
    
    init(_ timestamp: Date, _ message: String) {
        self.timestamp = timestamp
        self.message = message
    }
    //func json() {
    //    try! JSONEncoder().encode(self)
   // }
}

struct ItemCodable : Codable{
    var timestamp: Date
    var message: String
    init(_ item:Item){
        timestamp = item.timestamp
        message   = item.message
    }
    func json()->String {
        let data = try! JSONEncoder().encode(self)
        return(String(data: data, encoding: .utf8)!)
    }
    static func item(_ s:String)->Item{
        do{
            var d = Data()
            //let index = s.firstIndex(of: "{") ?? s.endIndex
            if let range = s.range(of: "]: "){
                let substring = s[range.upperBound...]
                d = substring.data(using: .utf8)!
            }
            let i = try JSONDecoder().decode(ItemCodable.self, from: d)
            return i.toItem()
        }
        catch{ return(Item(Date(),s))}
    }
    func toItem()->Item{
        Item(timestamp,message)
    }
}
