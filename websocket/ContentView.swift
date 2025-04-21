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
let url_1 = URL(string: "ws://localhost:8080/chat?username=U1")!
let url_2 = URL(string: "ws://localhost:8080/chat?username=U2")!

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State var message = ""

    let webSocketTask1 = urlSession.webSocketTask(with: url_1)
    let webSocketTask2 = urlSession.webSocketTask(with: url_2)

    
    var body: some View {
         NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                        Text(item.message)
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                        Text(item.message)
                    }
                }
            }.toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                /*ToolbarItem {
                    Button(action: {modelContext.delete(item)}) {
                        Label("Delete Item", systemImage: "trash")
                    }
                }*/
                ToolbarItem {
                    Button(action: sendMessageTask) {
                        Label("send messages", systemImage: "square.and.arrow.up")
                    }
                }
            }


        } detail: {
            Text("Select an item")
            Text("websocket server at \(message)")
            Text("total  message count = \(items.count)")
            Button("Send message to WS"){
                sendMessageTask()            }
        }
        .task{
            message = date2string()

            await WSserver()
        }
    }
    private func sendMessageTask() {
        Task{ await sendMesssage(webSocketTask1,"XX")}
        Task{ await sendMesssage(webSocketTask2,"YY")}
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(Date(),"Msg-\(msg_cnt)")
            msg_cnt += 1
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
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
func sendMesssage2(username:String) async{
    let url = URL(string: "ws://localhost:8080/chat?username=\(username)")!
    let urlSession = URLSession(configuration: .default)
    let webSocketTask = urlSession.webSocketTask(with: url)
    webSocketTask.resume()
    let messages = Array(0...3)
        .map{URLSessionWebSocketTask.Message.string(username+String($0))}
    for message in messages {
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket sending error: \(error)")
            }
        }
    }
    for _ in 0...110{
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("\(username) Received text message: \(text)")
                case .data(let data):
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
            }
        }

    }
    try! await Task.sleep(nanoseconds: 10_000_000_000)
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
    func sendMesssage(_ webSocketTask:URLSessionWebSocketTask,
                      _ username:String) async{
        //let url = URL(string: "ws://localhost:8080/chat?username=\(username)")!
        //let urlSession = URLSession(configuration: .default)
        //let webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask.resume()
        let messages = Array(0...99)
            .map{URLSessionWebSocketTask.Message.string(
                ItemCodable(Item(.now,String($0) )).json())}
            //.map{URLSessionWebSocketTask.Message.string(username+String($0))}
        for message in messages {
            webSocketTask.send(message) { error in
                if let error = error {
                    print("WebSocket sending error: \(error)")
                }
            }
        }
        while true {
            let message = try! await webSocketTask.receive()
            switch message {
            case .string(let text):
                print("\(username) Received text message: \(text)")
                //modelContext.insert(Item(Date(),text))
                modelContext.insert(ItemCodable.item(text))
            case .data(let data):
                print("Received binary message: \(data)")
            @unknown default:
                fatalError("\(#function)")
            }
        }
    }}
func sendMesssage1() async{
    let url = URL(string: "ws://localhost:8080/chat?username=Tib")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print(error);print("----  1  -----")
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
            print(response);print("----  2  -----")
            return
        }
        if let mimeType = httpResponse.mimeType, mimeType == "text/html",
            let data = data,
            let string = String(data: data, encoding: .utf8) {
            print("in http response");print("----  3  -----")
            //DispatchQueue.main.async {
             //   self.webView.loadHTMLString(string, baseURL: url)
            //}
        }
    }
    task.resume()
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
