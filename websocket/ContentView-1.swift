//
//  ContentView-1.swift
//  websocket
//
//  Created by steve on 2025/4/21.
//

import SwiftUI
import SwiftData

struct ContentView1: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatUser.name)  private var users: [ChatUser]
    @Query(sort: \ChatGroup.createTime)  private var groups: [ChatGroup]
    @Query(sort: \ChatMessage.createTime)  private var messages: [ChatMessage]

    var body: some View {
        NavigationSplitView {
            List {
                Section("user"){
                    ForEach(users) { user in
                        NavigationLink {
                            ChatUserDetail(user: user)
                            //TextField("new name", text: Bindable(user).name)
                        } label: {
                            Text(user.name)
                        }
                    }
                    //.onDelete(perform: deleteUsers(offsets:))
                }
                Section("group"){
                    ForEach(groups) { group in
                        NavigationLink {
                            ChatGroupDetail(group: group)
                        } label: {
                            Text(group.name)
                        }
                    }
                }
                Section("message"){
                    ForEach(messages) { message in
                        NavigationLink {
                            ChatMessageDetail(message: message)
                        } label: {
                            Text(message.message)
                        }
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
}
extension Date{
    func uint()-> Int { return (Int(self.timeIntervalSince1970*100000)%1000000)}
}
#Preview {
    ContentView()
    .modelContainer(SampleData.shared.modelContainer)
}
