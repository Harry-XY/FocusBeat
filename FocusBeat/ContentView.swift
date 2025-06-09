//
//  ContentView.swift
//  FocusBeat
//
//  Created by Harry Geng on 2025/05/26.
//

import SwiftUI
import UserNotifications 

struct ContentView: View{
    @State private var timeRemaining = 25 * 60
    @State private var isRunning = false
    @State private var timer: Timer? = nil
    @State private var isBreakTime = false
    @State var isShowingSettingsView = false
    @State var isShowingHistoryView = false
    @State private var heartBeatAnimation = false
    @AppStorage("workDuration_seconds") var workDuration = 25 * 60
    @AppStorage("breakDuration_seconds") var breakDuration = 5 * 60
    
    var body: some View {
        NavigationStack{
            VStack {
                HeartBeat
                
                Spacer()
                
                TimeZone
                
                StartButton
                
                Spacer()
                
                ResetSkipButtons
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isRunning ? Color.black : Color.dirty)
            .toolbar{
                appToolbarContent
            }
            .onChange(of: workDuration) { oldValue, newValue in
                // 当 workDuration (专注时长设置) 改变时
                if !isRunning && !isBreakTime { // 如果计时器未运行，且当前是专注模式
                    self.timeRemaining = newValue // 更新 timeRemaining 为新的专注时长
                }
            }
            .onChange(of: breakDuration) { oldValue, newValue in
                // 当 breakDuration (休息时长设置) 改变时
                if !isRunning && isBreakTime { // 如果计时器未运行，且当前是休息模式
                    self.timeRemaining = newValue // 更新 timeRemaining 为新的休息时长
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

extension ContentView {
    // MARK: - Local Notifications
    private func scheduleLocalNotification(title: String, body: String, sound: UNNotificationSound = .default) {
        // 1. 创建通知的内容
        let content = UNMutableNotificationContent()
        content.title = title // 使用传入的标题
        content.body = body   // 使用传入的正文
        content.sound = sound // 使用传入的声音
        
        // 2. 创建触发器 (我们希望通知立即触发，因为是在计时结束后调用)。设置一个极短的时间间隔，如0.1秒，以确保系统有时间处理并显示通知
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // 3. 创建通知请求
        // 使用 UUID 来为每个请求创建一个唯一的ID，防止它们相互覆盖
        let requestIdentifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        // 4. 将请求添加到通知中心
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("安排本地通知时发生错误: \(error.localizedDescription)")
            } else {
                print("本地通知已成功安排: \(title)")
            }
        }
    }
    
    //MARK: -ToolBar
    @ToolbarContentBuilder
    private var appToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                isShowingSettingsView = true
            } label: {
                Image(systemName: "gearshape")
            }
            .foregroundStyle(isRunning ? Color.white : Color.black)
            .sheet(isPresented: $isShowingSettingsView) {
                SettingsView()
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isShowingHistoryView = true
            } label: {
                Image(systemName: "list.bullet")
            }
            .foregroundStyle(isRunning ? Color.white : Color.black)
            .sheet(isPresented: $isShowingHistoryView){
                HistoryView()
            }
        }
    }
    
    // MARK: - Beating Heart
    private var HeartBeat: some View {
        HStack{
            Image(systemName: "heart.fill")
                .foregroundStyle(.darkRed)
                .scaleEffect(heartBeatAnimation ? 1 : 0.9) // 根据状态放大或恢复
                .animation( // 添加动画效果
                    Animation.easeInOut(duration: 0.37) // 动画曲线和时长
                        .repeatForever(autoreverses: true), value: heartBeatAnimation
                    // 动画依赖于 heartBeatAnimation 的变化
                )
            Text("90 BMP")
                .padding()
                .foregroundStyle(isRunning ? Color.white : Color.black)
        }
        .onAppear { // 当视图出现时
            self.heartBeatAnimation.toggle() // 触发初始动画状态改变
        }
        .font(.system(size: 30, weight: .bold, design: .monospaced))
    }
    
    //MARK: -TimeZone
    
    private var TimeZone: some View{
        VStack{
            Text(currentModeText)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
            
            Text(formatTime(timeRemaining))
                .font(.system(size: 90, weight: .bold, design: .monospaced))
        }
        .foregroundStyle(isRunning ? Color.white : Color.black)
    }
    
    
    var currentModeText: String {
        if isBreakTime {
            return "BREAK"
        } else {
            return "FOCUS"
        }
    }
    
    
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    //MARK: -Start
    private var StartButton: some View{
        Button {
            startTimer()
        }label: {
            HStack{
                if isRunning{
                    Image(systemName: "pause")
                    Text(dynamicStartButtonText)
                }else{
                    Image(systemName: "play")
                    Text(dynamicStartButtonText)
                }
            }
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .padding()
            .frame(width: 200)
            .background(isRunning ? Color.white : Color.black)
            .foregroundStyle(isRunning ? Color.black : Color.white)
            .cornerRadius(10)
        }
    }
    
    
    var dynamicStartButtonText: String {
        if isRunning {
            return "Pause"
        } else {
            if isBreakTime {
                return "Start Break"
            } else {
                return "Start Focus"
            }
        }
    }
    
    func startTimer() {
        if isRunning {
            timer?.invalidate()
            //.invalidate()：是 Timer 类型的方法，表示“使这个 Timer 失效”，也就是停止计时器。
            timer = nil
            isRunning = false
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    DispatchQueue.main.async {
                        timeRemaining -= 1
                    }
                } else {
                    DispatchQueue.main.async {
                        // 1. 先停止当前计时器和更新 isRunning
                        timer?.invalidate()
                        timer = nil
                        isRunning = false
                        
                        // 2. 然后根据 isBreakTime 的状态决定下一个周期
                        if isBreakTime { // 如果当前是休息时间 (意味着休息结束了)
                            // TODO: 设置为专注时间
                            timeRemaining = workDuration // 准备下一个专注时间
                            isBreakTime = false          // 切换到专注模式
                        } else { // 如果当前是专注时间 (意味着专注结束了)
                            // TODO: 设置为休息时间
                            timeRemaining = breakDuration // 准备下一个休息时间
                            isBreakTime = true           // 切换到休息模式
                        }
                    }
                }
            }
        }
    }
    
    //MARK: -RestAndSkip
    
    private var ResetSkipButtons: some View {
        HStack{
            Button {
                resetTimer()
            }label: {
                HStack{
                    Image(systemName: "arrow.clockwise")
                    Text("Reset")
                }
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .frame(width: 150)
                .foregroundStyle(isRunning ? Color.white : Color.black)
            }
            
            Button {
                skipTimer()
            }label: {
                HStack{
                    Image(systemName: "forward.end")
                    Text("Skip")
                }
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .frame(width: 150)
                .foregroundStyle(isRunning ? Color.white : Color.black)
            }
        }
        .padding()
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        timeRemaining = workDuration
        isBreakTime = false
    }
    
    func skipTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        if isBreakTime {
            timeRemaining = workDuration
            isBreakTime = false
        }else{
            timeRemaining = breakDuration
            isBreakTime = true
        }
    }
    
}

