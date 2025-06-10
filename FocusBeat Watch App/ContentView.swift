//
//  ContentView.swift
//  FocusBeat Watch App
//
//  Created by Harry Geng on 2025/05/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var watchService = WatchConnectivityService()
    
    var body: some View {
        VStack {
           
            // 直接显示来自 watchService 的 receivedMessage 属性
            Text(watchService.receivedMessage)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
