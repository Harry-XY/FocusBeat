//
//  FocusBeatApp.swift
//  FocusBeat
//
//  Created by Harry Geng on 2025/05/26.
//

import SwiftUI
import UserNotifications

@main
struct FocusBeatApp: App {
    init() {
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限获取成功！")
            } else if let error = error {
                print("获取通知权限时发生错误: \(error.localizedDescription)")
            } else {
                print("用户拒绝了通知权限。")
            }
        }
    }
}
