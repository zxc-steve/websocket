//
//  ContentView.swift
//  websocket
//
//  Created by steve on 2025/4/6.
//
/*
 https://swiftonserver.com/websockets-tutorial-using-swift-and-hummingbird/
 https://medium.com/@thomsmed/real-time-with-websockets-and-swift-concurrency-8b44a8808d0d
 */

import SwiftUI
import SwiftData
//import Hummingbird
typealias WSmessage = URLSessionWebSocketTask.Message
var msg_cnt = 0
let urlSession = URLSession(configuration: .default)
let urls = [URL(string: "ws://localhost:8080/chat?username=X1")!,
            ]

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatUser.name)  private var users: [ChatUser]
    @Query(sort: \ChatGroup.createTime)  private var groups: [ChatGroup]
    @Query(sort: \ChatMessage.message)  private var messages: [ChatMessage]

    @State var startTime = ""

    let webSocketTasks = urls.map{urlSession.webSocketTask(with: $0)}

    
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
            Text("websocket server at \(startTime)")
            Text("total  message count = \(messages.count)")
            Button("Send message to WS"){
                sendMessageTask()            }
        }
        .task{
            startTime = date2string()
            await webSocketInit()
        }.toolbar {
            ToolbarItem {
                Button(action: sendMessageTask) {
                    Label("send messages", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}
func WSserver()async{
    /*let hostname: String = "127.0.0.1"
    let port: Int = 8080
    
    func run() async throws {
        let app = buildApplication(
            configuration: .init(
                address: .hostname(hostname, port: port),
                serverName: "Hummingbird"
            )
        )
        try await app.runService()
    }
    try! await run()*/
    try! await buildApplication().runService()
}
func date2string()->String{
    let today = Date.now
    let formatter3 = DateFormatter()
    formatter3.dateFormat = "HH:mm E, d MMM y"
    return formatter3.string(from: today)
}
// This function is not used now ! Convert callback to async stream
func WSmessageReceive(_ webSocketTask:URLSessionWebSocketTask) -> AsyncStream<String>{
    AsyncStream { () in
        /*  guard let self else {
         // Self is gone, return nil to end the stream
         return nil
         }*/
        var result : String = ""
        let message = try! await webSocketTask.receive()
        switch message {
        case .string(let text):
            print("Received text message: \(text)")
            result = text
        case .data(let data):
            print("Received binary message: \(data)")
        @unknown default:
            fatalError("\(#function)")
        }
        // End the stream (by returning nil) if the calling Task was canceled
        return Task.isCancelled ? nil : result
    }
}
extension ContentView {
    func webSocketInit() async{
        
        for (index,webSocketTask) in webSocketTasks.enumerated() {
            webSocketTask.resume()
            Task{
                while true {
                    let WSmessage = try! await webSocketTask.receive()
                    switch WSmessage {
                    case .string(let text):
                        print("X\(index) Received text message: \(text)")
                        WSmessageDecode(WSmessage: text)
                    case .data(let data):
                        print("Received binary message: \(data)")
                    @unknown default:
                        fatalError("\(#function)")
                    }
                }
            }

        }
    }

    private func sendMessageTask() {
        for (index,webSocketTask) in webSocketTasks.enumerated() {
            Task{
                await sendMesssage(webSocketTask)
            }
        }
    }
    func sendMesssage(_ webSocketTask:URLSessionWebSocketTask) async{

        let sentMessages = messages[0...3]  // first copy query messages to avoid multiple update
        for message in sentMessages {
            let jsonString = getChatModelJson(message)
            let WSmessage  = URLSessionWebSocketTask.Message.string(jsonString)
            webSocketTask.send(WSmessage) { error in
                if let error = error {
                    print("WebSocket sending error: \(error)")
                }
            }
        }
    }
    func WSmessageDecode(WSmessage:String){
        let userAndMessage = /^\[(\w+)]:(.*)/.dotMatchesNewlines(true)

        guard let match = WSmessage.firstMatch(of: userAndMessage)
        else {
            modelContext.insert(ChatMessage(WSmessage))
            return
        }
        let userName = String(match.1)
        let message  = String(match.2)
        chatModelDecode(message)
        try! modelContext.save()
    }
    func getUser(userName:String)->  ChatUser? { users.first{$0.name==userName}}
    func getGroup(groupName:String)->ChatGroup?{groups.first{$0.name==groupName}}
    
    func upsert(_ messagex:ChatMessagex){
        let chatMessage = messagex.newChatMessage()
        modelContext.insert(chatMessage)  // debug concurency
        
        guard let groupName = messagex.group
        else{ return }
        if let group = getGroup(groupName: groupName) {
            chatMessage.group = group
        } else{
            let newGroup = ChatGroup(groupName); modelContext.insert(newGroup)
            chatMessage.group = newGroup
        }
        //let newGroup = ChatGroup(groupName); modelContext.insert(newGroup)
        //chatMessage.group = newGroup
        
        guard let userName = messagex.from
        else{ return }
        if let user = getUser(userName: userName) {
            chatMessage.from = user
        } else{
            let newUser = ChatUser(userName); modelContext.insert(newUser)
            chatMessage.from = newUser
        }
        
        // ChatUser.name is unique, so it overwrite the same chatuser
        // This failed if concurrent upsert the same user/group too often !! 2025/04/28
        //let newUser = ChatUser(userName); modelContext.insert(newUser)
        //chatMessage.from = newUser

       // try! modelContext.save()

    }
    func upsert(_ userx:ChatUserx){
        let userName = userx.name
        if let user = getUser(userName: userName) {
            return
        } else{
            let newUser = ChatUser(userName); modelContext.insert(newUser)
        }
    }
    func upsert(_ groupx:ChatGroupx){
        let groupName = groupx.name
        if let group = getGroup(groupName: groupName) {
            // merge group user
        } else{
            let newGroup = ChatGroup(groupName); modelContext.insert(newGroup)
            // find and copy group user
        }
    }
    func chatModelDecode(_ msg:String){
        let decoder = JSONDecoder()
        if let chatMessagex = try? decoder.decode(ChatMessagex.self, from: msg.data(using: .utf8)!){
            upsert(chatMessagex)
        } else if let chatUserx = try? decoder.decode(ChatUserx.self, from: msg.data(using: .utf8)!){
            upsert(chatUserx)
        } else if let chatGroupx = try? decoder.decode(ChatGroupx.self, from: msg.data(using: .utf8)!){
            upsert(chatGroupx)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
