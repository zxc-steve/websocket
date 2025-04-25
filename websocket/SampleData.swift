//
//  SampleData.swift
//  swift server
//
//  Created by steve on 2025/3/31.
//
import Foundation
import SwiftData


@MainActor
class SampleData {
    static let shared = SampleData()

    let modelContainer: ModelContainer
    var context: ModelContext {
        modelContainer.mainContext
    }

    private init() {
        let schema = Schema([
            ChatUser.self,ChatGroup.self,ChatMessage.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            //print("begin try ModelContainer")
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            //let users = try context.fetch(FetchDescriptor<ChatUser>())
           // if  users.count == 0 {
                print("Loading sample data \(Date.now)!")
            insertSampleData1(context)
                try context.save()
                print(try context.fetch(FetchDescriptor<ChatUser>()).count)
            //}
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    static func insertSampleData(_ context : ModelContext) {

        for user in ChatUser.sampleData {context.insert(user)}
        for group in ChatGroup.sampleData {context.insert(group)}
        for message in ChatMessage.sampleData {context.insert(message)}

        ChatGroup.sampleData[0].users = [ChatUser.sampleData[0]]
        ChatGroup.sampleData[1].users = [ChatUser.sampleData[2]]
        ChatGroup.sampleData[2].users = [ChatUser.sampleData[0],
                                         ChatUser.sampleData[1],
                                        ]
        ChatGroup.sampleData[3].users = [ChatUser.sampleData[0],
                                         ChatUser.sampleData[1],
                                         ChatUser.sampleData[2],
                                        ]
        ChatMessage.sampleData[0].from = ChatUser.sampleData[0]
        ChatMessage.sampleData[1].from = ChatUser.sampleData[1]
        ChatMessage.sampleData[2].from = ChatUser.sampleData[2]
        ChatMessage.sampleData[3].from = ChatUser.sampleData[0]
        ChatMessage.sampleData[4].from = ChatUser.sampleData[1]
        ChatMessage.sampleData[5].from = ChatUser.sampleData[1]
        ChatMessage.sampleData[6].from = ChatUser.sampleData[2]
        ChatMessage.sampleData[7].from = ChatUser.sampleData[0]
        ChatMessage.sampleData[8].from = ChatUser.sampleData[1]
        ChatMessage.sampleData[9].from = ChatUser.sampleData[0]
        
        ChatMessage.sampleData[0].group = ChatGroup.sampleData[0]
        ChatMessage.sampleData[1].group = ChatGroup.sampleData[1]
        ChatMessage.sampleData[2].group = ChatGroup.sampleData[2]
        ChatMessage.sampleData[3].group = ChatGroup.sampleData[3]
        ChatMessage.sampleData[4].group = ChatGroup.sampleData[0]
        ChatMessage.sampleData[5].group = ChatGroup.sampleData[0]
        ChatMessage.sampleData[6].group = ChatGroup.sampleData[1]
        ChatMessage.sampleData[7].group = ChatGroup.sampleData[1]
        ChatMessage.sampleData[8].group = ChatGroup.sampleData[2]
        ChatMessage.sampleData[9].group = ChatGroup.sampleData[0]
    }
    func insertSampleData1(_ context : ModelContext) {
        let UsampleData = [
            ChatUser("U0"),
            ChatUser("U1"),
            ChatUser("U2"),
            ChatUser("U3"),
        ]
        let GsampleData = [
            ChatGroup("G0"),
            ChatGroup("G1"),
            ChatGroup("G2"),
            ChatGroup("G3"),
      ]
        let MsampleData = [
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

        for user in UsampleData {context.insert(user)}
        for group in GsampleData {context.insert(group)}
        for message in MsampleData {context.insert(message)}
        //for user in userSample {context.insert(user);print (user.name)}

        //  begin relationship setup
        // first group to user
        GsampleData[0].users = [UsampleData[0]]
        GsampleData[1].users = [UsampleData[2]]
        GsampleData[2].users = [UsampleData[0],
                                UsampleData[1],
                                        ]
        GsampleData[3].users = [UsampleData[0],
                                UsampleData[1],
                                UsampleData[2],
                                        ]
        MsampleData[0].from = UsampleData[0]
        MsampleData[1].from = UsampleData[1]
        MsampleData[2].from = UsampleData[2]
        MsampleData[3].from = UsampleData[0]
        MsampleData[4].from = UsampleData[1]
        MsampleData[5].from = UsampleData[1]
        MsampleData[6].from = UsampleData[2]
        MsampleData[7].from = UsampleData[0]
        MsampleData[8].from = UsampleData[1]
        MsampleData[9].from = UsampleData[0]
        
        MsampleData[0].group = GsampleData[0]
        MsampleData[1].group = GsampleData[1]
        MsampleData[2].group = GsampleData[2]
        MsampleData[3].group = GsampleData[3]
        MsampleData[4].group = GsampleData[0]
        MsampleData[5].group = GsampleData[0]
        MsampleData[6].group = GsampleData[1]
        MsampleData[7].group = GsampleData[1]
        MsampleData[8].group = GsampleData[2]
        MsampleData[9].group = GsampleData[0]
    }
}



