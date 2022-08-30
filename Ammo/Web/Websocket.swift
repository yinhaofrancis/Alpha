//
//  Websocket.swift
//  Ammo
//
//  Created by hao yin on 2022/8/23.
//

import Foundation

public class Websocket:NSObject,URLSessionWebSocketDelegate{
    lazy public var session:URLSession = {
        let session = URLSession(configuration: self.configuration)
        return session
    } ()
    lazy private var configuration:URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        return config
    }()
    @discardableResult
    public func connect(route:String,handle:@escaping (WebsocketRoute,URLSessionWebSocketTask.Message?, Error?) -> Void)->WebsocketRoute?{
        guard let url = URL(string: route) else { return nil }
        let task = self.session.webSocketTask(with:url)
        let r =  WebsocketRoute(route: url, task: task, getData: handle)
        self.routes[url] = r
        return r
    }
    var routes:[URL:WebsocketRoute] = [:]
    public class WebsocketRoute{
        public var task:URLSessionWebSocketTask
        
        public weak var manager:Websocket?
        private var callback:(WebsocketRoute,URLSessionWebSocketTask.Message?,Error?)->Void
        public var route:URL
        public init(route:URL,task:URLSessionWebSocketTask,getData:@escaping (WebsocketRoute,URLSessionWebSocketTask.Message?,Error?)->Void){
            self.route = route
            self.task = task
            self.callback = getData
            self.recieve()
        }
        private func recieve(){
            
            self.task.receive { [weak self]r in
                guard let ws = self else { return }
                
                do{
                    ws.callback(ws,try r.get(),nil)
                    
                }catch{
                    ws.callback(ws,nil,error)
                }
                
            }
        }
        public func send(data:Data,completeHandler:@escaping (Error?)->Void){
            self.recieve()
            self.task.send(.data(data),completionHandler: completeHandler)
        }
        public func send(string:String,completeHandler:@escaping (Error?)->Void){
            self.recieve()
            self.task.send(.string(string), completionHandler: completeHandler)
        }
        public func cancel(){
            self.task.cancel()
            self.manager?.routes.removeValue(forKey: self.route)
        }
        public func connect(){
            self.task.resume()
        }
    }
    public static let shared:Websocket = {
        Websocket()
    }()
}
