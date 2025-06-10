//
//  WatchConnectivityService.swift
//  FocusBeat (iPhone)
//
//  Created by Harry Geng on 2025/06/10.
//

import Foundation
import WatchConnectivity

// 最终的、完整的 iPhone 端通信服务

class WatchConnectivityService: NSObject, WCSessionDelegate, ObservableObject {
    
    // MARK: - Properties
    
    // @Published 属性可以让 SwiftUI 视图监听它的变化。
    // 我们用它来存放未来从手表接收到的最新消息。
    @Published var receivedMessage: [String: Any] = [:]
    
    private var session: WCSession = .default
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        
        // 检查当前设备是否支持 Watch Connectivity
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - Public Methods
    
    /// 发送一个实时消息到 Apple Watch
    /// - Parameter message: 一个包含要发送数据的字典 [String: Any]
    func sendMessage(_ message: [String: Any]) {
        guard session.isReachable else {
            print("sendMessage failed: Watch is not reachable.")
            // 在这里可以处理无法发送的情况，比如通过UI提示用户
            return
        }
        
        session.sendMessage(message, replyHandler: nil) { error in
            // 我们换一种不使用 if let 的检查方式
            if error != nil {
                // 如果 error 不是 nil，我们已经确认它有值
                // 所以在这里用感叹号 ! 来强制解包是安全的
                print("Error sending message: \(error!.localizedDescription)")
            } else {
                print("Message sent successfully from iPhone: \(message)")
            }
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    
    // 当会话激活完成时调用 (在iOS上必须实现)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error != nil {
            print("WCSession activation failed on iPhone with error: \(error!.localizedDescription)")
            return
        }
        
        // 使用 switch 语句打印更详细的激活状态，方便调试
        switch activationState {
        case .activated:
            print("WCSession (iPhone) is activated.")
        case .inactive:
            print("WCSession (iPhone) is inactive.")
        case .notActivated:
            print("WCSession (iPhone) is not activated.")
        @unknown default:
            print("WCSession (iPhone) has an unknown activation state.")
        }
    }
    
    // 当收到来自手表的实时消息时调用
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // 这个方法在后台线程被调用，所以需要切换到主线程来更新 @Published 属性
        DispatchQueue.main.async {
            self.receivedMessage = message
            print("Received message from Watch: \(message)")
        }
    }
    
    // 以下两个代理方法在 iOS 上是必需的
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // 当会话不再是活动状态时调用，比如用户切换了配对的手表。
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // 当会话被系统停用时调用。苹果建议在这里再次激活会话。
        session.activate()
    }
}
