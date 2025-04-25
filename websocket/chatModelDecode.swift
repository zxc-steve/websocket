//
//  chatModelDecode.swift
//  websocket
//
//  Created by steve on 2025/4/23.
//
import SwiftUI
import SwiftData
import Foundation
/*
extension ContentView {
    func sendMesssage(_ webSocketTask:URLSessionWebSocketTask,
                      _ username:String) async{
        //let url = URL(string: "ws://localhost:8080/chat?username=\(username)")!
        //let urlSession = URLSession(configuration: .default)
        //let webSocketTask = urlSession.webSocketTask(with: url)
        let chatUsers = [ChatUser("U0"),ChatUser("U1"),ChatUser("U2"),]
        let chatMessages = [ChatMessage("M0"),ChatMessage("M1"),ChatMessage("M2"),]
        for i in 0...2 {
            modelContext.insert(chatUsers[i])
            modelContext.insert(chatMessages[i])
        }
        chatMessages[0].from = chatUsers[0]
        chatMessages[1].from = chatUsers[1]
        chatMessages[2].from = chatUsers[2]
        print(chatMessages[0].from?.name)
        print(getChatModelJson(chatMessages[1])) // for debug
        
        webSocketTask.resume()
        let messages = Array(0...2)
            .map{URLSessionWebSocketTask.Message.string(
               // getChatModelJson(ChatMessage("M"+String($0)))
                getChatModelJson(chatMessages[$0])
            )}
        //.map{URLSessionWebSocketTask.Message.string(username+String($0))}
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
                print("\(username) Received text message: \(text)")
                //modelContext.insert(ChatMessage(WSmessage:text,0))
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
*/
