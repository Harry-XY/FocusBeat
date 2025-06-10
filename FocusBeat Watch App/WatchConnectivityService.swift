import Foundation
import WatchConnectivity

class WatchConnectivityService: NSObject, WCSessionDelegate, ObservableObject {
    
    // 1. 【添加】声明一个 @Published 属性来存储收到的消息
    // SwiftUI 会监听这个属性的变化，并自动更新界面
    @Published var receivedMessage: String = "No message yet"
    
    private var session: WCSession = .default
    
    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }
    
    // 2. 【添加】实现接收消息的代理方法
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // message 是一个字典，就像在 iPhone 上定义的那样 ["text": "Hello..."]
        // 我们尝试从中取出 "text" 键对应的值
        // 因为这个方法在后台线程执行，更新 UI 需要切换到主线程
        DispatchQueue.main.async {
            self.receivedMessage = message["text"] as? String ?? "Invalid message format"
            print("Received message from iPhone: \(self.receivedMessage)")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession (Watch) activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession (Watch) activated with state: \(activationState.rawValue)")
        }
    }
}
