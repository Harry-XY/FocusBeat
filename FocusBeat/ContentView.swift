//
//  ContentView.swift
//  FocusBeat
//
//  Created by Harry Geng on 2025/05/26.
//

import SwiftUI
import UserNotifications

struct AlertInfo: Identifiable {
    let id = UUID() // Identifiable 协议要求
    var title: String
    var message: String
}

struct ContentView: View{
    @State private var timeRemaining: Int
    @State private var isRunning = false
    @State private var timer: Timer? = nil
    @State private var isBreakTime = false
    @State var isShowingSettingsView = false
    @State var isShowingHistoryView = false
    @State private var heartBeatAnimation = false
    @AppStorage("workDuration_seconds") var workDuration = 25 * 60
    @AppStorage("breakDuration_seconds") var breakDuration = 5 * 60
    @State private var alertInfo: AlertInfo?
    @Environment(\.scenePhase) private var scenePhase
    @State private var endDate: Date?
    @StateObject private var watchService = WatchConnectivityService() 
    
    
    init() {
        // 1. 直接从 UserDefaults 中读取我们存储的值
        //    我们使用的键 "workDuration_seconds" 必须和 @AppStorage 中的完全一样
        let savedDuration = UserDefaults.standard.integer(forKey: "workDuration_seconds")
        
        // 2. 判断是否成功读取到了有效值，不然使用默认
        let initialDuration = (savedDuration > 0) ? savedDuration : (25 * 60)
        
        // 3. 用这个正确的初始值来初始化 _timeRemaining
        _timeRemaining = State(initialValue: initialDuration)
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                HeartBeat
                Spacer()
                TimeZone
                StartButton
                Spacer()
                Button("Send Message to Watch") {
                    let message = ["text": "Hello from iPhone!"]
                    // 调用我们 service 中的方法来发送消息
                    watchService.sendMessage(message)
                }
                .padding()
                
                ResetSkipButtons
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isRunning ? Color.black : Color.dirty)
            .toolbar{
                appToolbarContent
            }
            .alert(item: $alertInfo) { info in
                Alert(
                    title: Text(info.title),
                    message: Text(info.message),
                    primaryButton: .default(Text("Start Next"), action: {
                        startTimer() // 点击后直接开始下一时段
                    }),
                    secondaryButton: .cancel(Text("Later")) // 点击后仅关闭弹窗
                )
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                // 当 App 从后台或非活跃状态，返回到活跃状态时
                if newPhase == .active {
                    // 我们需要检查计时器是否本应在运行
                    if let endDate = self.endDate {
                        // 如果是，我们立即重新计算剩余时间
                        let remaining = Int(endDate.timeIntervalSinceNow.rounded())
                        
                        if remaining <= 0 {
                            //如果计算后发现时间其实在后台时就已经结束了，就直接调用会话结束处理函数
                            self.handleSessionEnd()
                        } else {
                            //如果时间还没结束，就用正确的时间更新UI，实现“赶上”进度
                            self.timeRemaining = remaining
                        }
                    }
                }
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
    private func scheduleLocalNotification(seconds: TimeInterval, title: String, body: String, sound: UNNotificationSound = .default) {
        // 1. 创建通知的内容
        let content = UNMutableNotificationContent()
        content.title = title // 使用传入的标题
        content.body = body   // 使用传入的正文
        content.sound = sound // 使用传入的声音
        
        // 2. 创建触发器
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        
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
    
    // MARK: - Notification Decision Logic
    private func triggerEndOfSessionActions(forPreviousSessionIsBreak: Bool) {
        // 1. 根据上一个会话的类型，准备好标题和消息文本
        let title: String
        let message: String
        
        if forPreviousSessionIsBreak {
            // 如果上一个会话是休息时段
            title = "Break's Over! "
            message = "Ready to get back to focus? Let's do this! "
        } else {
            // 如果上一个会话是专注时段
            title = "Focus Complete! "
            message = "Time for a well-deserved break. "
        }
        
        // 2. 检查 App 的当前状态
        if scenePhase == .active {
            // 如果 App 在前台，触发 Alert 弹窗
            // 我们通过设置之前创建的 alertInfo 状态变量来做到这一点
            self.alertInfo = AlertInfo(title: title, message: message)
        }
    }
    
    // MARK: - Session End Handler
    private func handleSessionEnd() {
        // 1. 停止计时器
        isRunning = false
        timer?.invalidate()
        endDate = nil // 清除结束时间
        
        // 2. 判断上一个会话是什么类型...
        if isBreakTime {
            triggerEndOfSessionActions(forPreviousSessionIsBreak: true)
            timeRemaining = workDuration
            isBreakTime = false
        } else {
            triggerEndOfSessionActions(forPreviousSessionIsBreak: false)
            timeRemaining = breakDuration
            isBreakTime = true
        }
    }
    
    //MARK: -StartTimer
    func startTimer() {
        if isRunning {
            // 1. 取消所有已预定的后台通知
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // 2. 停止 UI 计时器
            timer?.invalidate()
            timer = nil
            isRunning = false
            
            // 3. 清除结束时间点，因为计时已经暂停
            endDate = nil
        } else {
            isRunning = true
            self.endDate = Date().addingTimeInterval(TimeInterval(timeRemaining))
            
            // 根据当前是什么时段，来提前安排对应的结束通知
            if !isBreakTime {
                // 如果一个“专注”时段正要开始...
                // ...我们就安排一个在它结束时提醒用户去休息的通知
                scheduleLocalNotification(seconds: TimeInterval(timeRemaining),
                                          title: "Focus Complete! ",
                                          body: "Time for a well-deserved break. ")
            } else {
                // 如果一个“休息”时段正要开始...
                // ...我们就安排一个在它结束时提醒用户回去专注的通知
                scheduleLocalNotification(seconds: TimeInterval(timeRemaining),
                                          title: "Break's Over! ",
                                          body: "Ready to get back to focus? Let's do this! ")
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                // 确保我们有一个有效的结束时间 (endDate)，如果没有，说明计时器不应该在运行
                guard let endDate = self.endDate else {
                    self.isRunning = false
                    self.timer?.invalidate()
                    return
                }
                
                // 计算当前距离结束时间还有多少秒
                // .rounded() 是为了四舍五入到最接近的整数秒
                let remaining = Int(endDate.timeIntervalSinceNow.rounded())
                
                if remaining > 0 {
                    // 如果还有剩余时间，就更新显示的倒计时
                    self.timeRemaining = remaining
                } else {
                    // 如果剩余时间小于等于0，说明时间到了（这是App在前台时的情况）
                    // 调用我们统一的会-话结束处理函数
                    self.handleSessionEnd()
                }
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
    
    // MARK: -Beating Heart
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
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        timer?.invalidate()
        timer = nil
        endDate = nil
        isRunning = false
        timeRemaining = workDuration
        isBreakTime = false
    }
    
    func skipTimer() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        handleSessionEnd()
    }
}
