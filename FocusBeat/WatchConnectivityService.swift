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
        
        // 正确的写法：分别提供成功和失败的处理代码
        session.sendMessage(message, replyHandler: { _ in
            // 这个代码块只在消息【成功】发送后执行
            // 注意：这里的 replyHandler 是可选的，如果你的 Watch App 不需要回复，
            // 那么这个 replyHandler 甚至可以不写。
            // 为了简单起见，我们假设成功就是成功，直接打印。
            print("Message sent successfully from iPhone: \(message)")
            
        }, errorHandler: { error in
            // 这个代码块只在消息【发送失败】时执行
            // 这里的 'error' 是一个确定的 Error，不是可选的，所以直接使用。
            print("sendMessage failed with error: \(error.localizedDescription)")
        })
    }
    
    // MARK: - WCSessionDelegate Methods
    
    // 当会话激活完成时调用 (在iOS上必须实现)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            // 直接执行操作，因为我们已经知道 error 肯定存在
            print("WCSession (iPhone) activation failed: \(error.localizedDescription)")
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
