//
//  MovieDetail.swift
//  swift server
//
//  Created by steve on 2025/4/1.
//


import SwiftUI
import SwiftData

struct ChatMessageDetail: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var message: ChatMessage
    @State var newMessage:String = ""
    let isNew : Bool
    
    init(message: ChatMessage, isNew: Bool = false) {
        self.message = message
        self.isNew = isNew
    }

    var body: some View {
        VStack {
            Text(getChatModelJson(message))
            if isNew {
                Picker("From",selection: $message.from){
                    ForEach(message.group!.users){user in
                        Text(user.name).tag(user)}
                }
                TextField("new message", text: $newMessage)
                    .onSubmit {saveMessage()}
            }
        }
        .navigationTitle(isNew ? "New ChatMessage" : "ChatMessage")
        //.navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNew {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {saveMessage()}
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        modelContext.delete(message)
                        dismiss()
                    }
                }
            }
        }

    }
    func saveMessage(){
        message.message = newMessage
        message.createTime = .now
        dismiss()
    }
}
struct ChatUserDetail: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    //@Query(sort: \ChatGroup.createTime)  private var groups: [ChatGroup]

    @Bindable var user: ChatUser
    //var user: ChatUser
    @State var newName : String = ""

    var body: some View {
        VStack {
            Text(getChatModelJson(user))
            TextField(user.name, text: $newName)
                .onSubmit {
                    user.name = newName
                    user.createTime = .now
                    newName = "U"
                    dismiss()
                }
            Button("Save"){
                user.name = newName
                user.createTime = .now
                newName = "U"
                dismiss()
            }
        }
        .navigationTitle("ChatUser")
        .toolbar {
            ToolbarItem {
                Button("Add ChatUser", systemImage: "plus", action: addChatUser)
            }
            ToolbarItem {
                Button("Delete ChatUser", systemImage: "trash", action: deleteChatUser)
            }
        }
        .onAppear(perform: {
            newName = user.name
        })
    }
    private func addChatUser(){
        let user = ChatUser(newName)
        modelContext.insert(user)
        print(user.name)
        print(user.createTime)
    }
    private func deleteChatUser(){
        modelContext.delete(user)
       // Task{try modelContext.save()}
        dismiss()
    }
}
struct ChatGroupDetail: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var group: ChatGroup
    @State private var selections = Set<ChatGroup>()
    @Query(sort: \ChatUser.name)  private var users: [ChatUser]
    @Query  private var messages: [ChatMessage]
    @State private var newMessage: ChatMessage?


    var body: some View {
        HStack{
            NavigationStack {
                List(users, selection: $selections) {user in
                    Text(user.name)
                        .foregroundColor(group.users.contains(user) ? .red:.gray)
                        .onTapGesture {
                            var s = Set(group.users)
                            if s.contains(user){ s.remove(user)}
                            else               { s.insert(user)}
                            group.users = Array(s)
                        }
                }
                .navigationTitle("ChatGroup")
                //.toolbar { Text("tools") }
                // .toolbar { EditButton() } not supported on Mac OS
            }
            Text(getChatModelJson(group))
            List(group.messages){message in
                ChatMessageDetail(message: message)
            }
        }
        .navigationTitle("ChatGroup")
        .toolbar {
            ToolbarItem {
                Button("Add message", systemImage: "plus", action: addMessage)
            }
        }
        .sheet(item: $newMessage) { message in
            NavigationStack {
                ChatMessageDetail(message: message, isNew: true)

            }
            .navigationTitle("New Message")
            .fixedSize()
        }
    }
    private func addMessage() {
        let newMessage = ChatMessage("M")
        modelContext.insert(newMessage)
        newMessage.group = group
        self.newMessage = newMessage
    }

}
func getChatModelJson<T:Encodable>(_ model:T)->String{
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys,.prettyPrinted]
    let data = try! encoder.encode(model)
    let strArray = String(data: data, encoding: .utf8)!.split(separator: "\n")
    var new = ""
    for s in strArray {
        if s.hasPrefix("   "){ new += s.trimmingCharacters(in: .whitespaces)
        } else { new = new + "\n" + s}
    }
    return(new)
   // return(new.filter{$0 != "\""})  // new is not json format,just for debug
}


#Preview {
    ContentView()
 .modelContainer(SampleData.shared.modelContainer)

}

