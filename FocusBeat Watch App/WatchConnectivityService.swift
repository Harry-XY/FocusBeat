//
//  WatchConnectivityService.swift
//  FocusBeat Watch App
//
//  Created by Harry Geng on 2025/06/10.
//

import Foundation
import WatchConnectivity

class WatchConnectivityService: NSObject, WCSessionDelegate, ObservableObject {
    
    private var session: WCSession = .default
    
    override init() {
        super.init()
        // 在 watchOS 上，WCSession 总是被支持的，所以我们可以直接设置代理并激活
        session.delegate = self
        session.activate()
    }
    
    // 在 watchOS 上，我们只需要实现这一个激活相关的代理方法
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession (Watch) activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession (Watch) activated with state: \(activationState.rawValue)")
        }
    }
}
