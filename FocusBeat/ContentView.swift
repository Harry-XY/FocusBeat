//
//  ContentView.swift
//  FocusBeat
//
//  Created by Harry Geng on 2025/05/26.
//

import SwiftUI

struct ContentView: View{
    @State private var timeRemaining: Int
    @State private var isRunning = false
    @State private var timer: Timer? = nil
    @State private var isBreakTime = false
    
    // MARK: - Constants for Durations
    let workDuration = 25 * 60 // 25 minutes in seconds
    let breakDuration = 5 * 60 // 5 minutes in seconds
    
    // Initialize timeRemaining with workDuration
    init() {
        _timeRemaining = State(initialValue: workDuration)
    }
    
    

    var body: some View {
        VStack {
            Text("Focus Beat")
                .font(.title)
                .bold()
                .foregroundStyle(isRunning ? Color.white : Color.black)
            
            Spacer()
            
            Text(currentModeText)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .foregroundStyle(isRunning ? Color.white : Color.black)
            
            Text(formatTime(timeRemaining))
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .foregroundStyle(isRunning ? Color.white : Color.black)
            
            Button {
                startTimer()
            }label: {
                HStack{
                    if isRunning{
                        Image(systemName: "pause")
                        Text("pause")
                    }else{
                        Image(systemName: "play")
                        Text("Start")
                    }
                }
                .font(.title)
                .padding()
                .frame(width: 150)
                .background(isRunning ? Color.white : Color.black)
                .foregroundStyle(isRunning ? Color.black : Color.white)
                .cornerRadius(10)
            }
            
            Spacer()
            
            Button {
                resetTimer()
            }label: {
                HStack{
                    Image(systemName: "arrow.clockwise")
                    Text("Reset")
                }
                .font(.title2)
                .frame(width: 150)
                .foregroundStyle(isRunning ? Color.white : Color.black)
            }
            
            Button {
                skipTimer()
            }label: {
                HStack{
                    Image(systemName: "arrowshape.zigzag.right")
                    Text("Skip")
                }
                .font(.title2)
                .frame(width: 150)
                .foregroundStyle(isRunning ? Color.white : Color.black)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isRunning ? Color.black : Color.white)
    }
    
    
}

#Preview {
    ContentView()
}

extension ContentView {
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
