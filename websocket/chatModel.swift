//
//  Item.swift
//  swift server
//
//  Created by steve on 2025/3/24.
//

import Foundation
import SwiftData

@Model
final class ChatUser: Codable{
    @Attribute(.unique) var name: String
    //var name: String
    var createTime: Date
    // many-to-many relationship must be explicit !
    @Relationship(deleteRule: .nullify, inverse: \ChatGroup.users)
    var inGroups = [ChatGroup]()
    //@Relationship(deleteRule: .nullify)//, inverse: \ChatMessage.from)
    var inMessages = [ChatMessage]()
    
    init(_ userName: String, _ createTime: Date = .now) {
        self.name = userName
        self.createTime = createTime
    }
    static let sampleData = [
        ChatUser("U0"),
        ChatUser("U1"),
        ChatUser("U2"),
        ChatUser("U3"),
    ]
    
    enum CodingKeys: String, CodingKey {
        case name
        case createTime
        case inGroups
        case inMessages
    }
     init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name      = try values.decode(String.self, forKey: .name)
        createTime = try values.decode(Date.self, forKey: .createTime)
       // inGroups   = try values.decode([ChatGroup].self, forKey: .inGroups)
       // inMessages = try values.decode([ChatMessage].self, forKey: .inMessages)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(inGroups.map{$0.name}, forKey: .inGroups)
        try container.encode(inMessages.count, forKey: .inMessages)
        try container.encode(inMessages.count, forKey: .inMessages)
    }

}
@Model
final class ChatGroup:Codable{
    //var users: Set<ChatUser> = []
    var users : [ChatUser] = []
    var messages : [ChatMessage] = []
    @Attribute(.unique) var name : String = ""
    var createTime: Date = Date.now

    init(_ groupName : String, groupUsers users : ChatUser...) {
        self.users = users
        self.name = groupName
    }
    init(_ groupName : String, _ createTime: Date = .now) {
        self.name = groupName
        self.createTime = createTime
    }
    static let sampleData = [
        ChatGroup("G0"),
        ChatGroup("G1"),
        ChatGroup("G2"),
        ChatGroup("G3"),
  ]
    
    enum CodingKeys: String, CodingKey {
        case name
        case createTime
        case users
        case messages
    }
     init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name       = try values.decode(String.self, forKey: .name)
        createTime = try values.decode(Date.self, forKey: .createTime)
        users      = try values.decode([ChatUser].self, forKey: .users)
        messages   = try values.decode([ChatMessage].self, forKey: .messages)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(createTime, forKey: .createTime)
        try container.encode(users.map{$0.name}, forKey: .users)
        //try container.encode(users.map{$0.name}.reduce("", {x,y in x+y+","}), forKey: .users)
        try container.encode(messages.count, forKey: .messages)
    }

}
@Model
final class ChatMessage:Codable {
     var group: ChatGroup?
   // @Relationship()
     var from: ChatUser?
    var message: String

    var createTime: Date = Date.now
    
    init(_ message : String, _ group : ChatGroup, from user: ChatUser) {
        self.message = message
        self.group = group
        self.from = user
    }
    init(_ message : String, _ createTime : Date = .now) {
        self.message    = message
        self.createTime = createTime
    }
    static let sampleData = [
        ChatMessage("M0"),
        ChatMessage("M1"),
        ChatMessage("M2"),
        ChatMessage("M3"),
        ChatMessage("M4"),
        ChatMessage("M5"),
        ChatMessage("M6"),
        ChatMessage("M7"),
        ChatMessage("M8"),
        ChatMessage("M9"),
        ]
    enum CodingKeys: String, CodingKey {
        case group
        case from
        case message
        case createTime
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        //group      = try values.decode(ChatGroup?.self, forKey: .group)
        //from       = try values.decode(ChatUser?.self, forKey: .from)
        message    = try values.decode(String.self, forKey: .message)
        createTime = try values.decode(Date.self, forKey: .createTime)
        //createTime = .now
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(group?.name, forKey: .group)
        try container.encode(from?.name, forKey: .from)
        try container.encode(message, forKey: .message)
        try container.encode(createTime, forKey: .createTime)
    }
}
//
// temparary struc for json decode from String
//
struct ChatUserx: Codable{
    //@Attribute(.unique) var name: String
    var name: String
    var createTime: Date
    // many-to-many relationship must be explicit !
    //@Relationship(deleteRule: .nullify, inverse: \ChatGroup.users)
    var inGroups = [String]()
    //@Relationship(deleteRule: .nullify)//, inverse: \ChatMessage.from)
    var inMessages = [String]()
    func newChatUser()->ChatUser{
        ChatUser(name,createTime)
    }

}
struct ChatGroupx:Codable{
    //var users: Set<ChatUser> = []
    var users : [String] = []
    var messages : [String] = []
    var name : String
    var createTime: Date
}
struct ChatMessagex:Codable {
    var group: String?
    // @Relationship()
    var from: String?
    var message: String
    var createTime: Date

    func newChatMessage()->ChatMessage{
        ChatMessage(message,createTime)
    }
}
