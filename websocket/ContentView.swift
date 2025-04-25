//
//  ContentView.swift
//  websocket
//
//  Created by steve on 2025/4/6.
//

import SwiftUI
import SwiftData
//import Hummingbird
typealias WSmessage = URLSessionWebSocketTask.Message
var msg_cnt = 0
let urlSession = URLSession(configuration: .default)
let url_1 = URL(string: "ws://localhost:8080/chat?username=Z1")!
let url_2 = URL(string: "ws://localhost:8080/chat?username=Z2")!
let url_3 = URL(string: "ws://localhost:8080/chat?username=Z3")!

struct ContentView: View {
   // @Environment(\.modelContext) private var modelContext
   // @Query private var items: [Item]
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatUser.name)  private var users: [ChatUser]
    @Query(sort: \ChatGroup.createTime)  private var groups: [ChatGroup]
    @Query(sort: \ChatMessage.createTime)  private var messages: [ChatMessage]

    @State var startTime = ""

    let webSocketUser1 = urlSession.webSocketTask(with: url_1)
    let webSocketUser2 = urlSession.webSocketTask(with: url_2)
    let webSocketUser3 = urlSession.webSocketTask(with: url_3)

    
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
            await WSserver()
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
    private func sendMessageTask() {
        Task{ await sendMesssage(webSocketUser1,"Z1")}
        /*Task{ //await try! Task.sleep(nanoseconds: 2_000_000_000)
            await sendMesssage(webSocketUser2,"Z2")
        }
        Task{ await sendMesssage(webSocketUser3,"Z3")}*/
    }
    func sendMesssage(_ webSocketTask:URLSessionWebSocketTask,
                      _ username:String) async{
        let chatUsers = [ChatUser("Y0"),ChatUser("Y1"),ChatUser("Y2"),]
        let chatMessages = [ChatMessage("X0"),ChatMessage("X1"),ChatMessage("X2"),]
        for i in 0...2 {
            modelContext.insert(chatUsers[i])
            modelContext.insert(chatMessages[i])
        }
        chatMessages[0].from = chatUsers[0]
        chatMessages[1].from = chatUsers[1]
        chatMessages[2].from = chatUsers[2]
        
        webSocketTask.resume()
        let messages = Array(0...2)
            .map{URLSessionWebSocketTask.Message.string(
                getChatModelJson(chatMessages[$0])
            )}

        for message in messages {
            webSocketTask.send(message) { error in
                if let error = error {
                    print("WebSocket sending error: \(error)")
                }
            }
        }
        while true {
            let WSmessage = try! await webSocketTask.receive()
            switch WSmessage {
            case .string(let text):
                print("\(username) Received text/json message: \(text)")
                WSmessageDecode(WSmessage: text)
            case .data(let data):
                print("Received binary message: \(data)")
            @unknown default:
                fatalError("\(#function)")
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
        modelContext.insert(chatMessage)
        
        guard let userName = messagex.from
        else{ return }
        /*if let user = getUser(userName: userName) {
            chatMessage.from = user
        } else{
            let newUser = ChatUser(userName); modelContext.insert(newUser)
            chatMessage.from = newUser
        }*/
        // ChatUser.name is unique, so it overwrite the same chatuser
        let newUser = ChatUser(userName); modelContext.insert(newUser)
        chatMessage.from = newUser

        
        guard let groupName = messagex.group
        else{ return }
        /*if let group = getGroup(groupName: groupName) {
            chatMessage.group = group
        } else{
            let newGroup = ChatGroup(groupName); modelContext.insert(newGroup)
            chatMessage.group = newGroup
        }*/
        let newGroup = ChatGroup(groupName); modelContext.insert(newGroup)
        chatMessage.group = newGroup

    }
    func upsert(_ userx:ChatUserx){
        let userName = userx.name
        let newUser = ChatUser(userName); modelContext.insert(newUser)

        //if let user = getUser(userName: userName) {
        //    return
        //} else{
        //    let newUser = ChatUser(userName); modelContext.insert(newUser)
        //}
    }
    func upsert(_ groupx:ChatGroupx){
        let groupName = groupx.name
        let newGroup = ChatGroup(groupName); modelContext.insert(newGroup)

        // merge group user, TBD
        /*if let group = getGroup(groupName: groupName) {
        } else{
            let newGroup = ChatGroup(groupName); modelContext.insert(newGroup)
            for user in groupx.users{
                if let chatUser = getUser(userName: user){
                    newGroup.users.append(chatUser)
                }
            }
        }*/
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
