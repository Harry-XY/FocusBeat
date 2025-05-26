//
//  ContentView.swift
//  FocusBeat
//
//  Created by Harry Geng on 2025/05/26.
//

import SwiftUI

struct ContentView: View{
@State private var timeRemaining = 25 * 60
@State private var isRunning = false
@State private var timer: Timer? = nil

    var body: some View {
        VStack {
            Spacer()
            
            Text(formatTime(timeRemaining))
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .foregroundStyle(isRunning ? Color.white : Color.black)
            
            Button {
                startTimer()
            }label: {
                Text(isRunning ? "Pause" : "Start")
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
                Text("Reset")
                    .font(.title2)
                    .padding()
                    .frame(width: 150)
                    .foregroundStyle(isRunning ? Color.white : Color.black)
                    .cornerRadius(10)
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
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    func startTimer() {
        DispatchQueue.main.async{
            if isRunning {
                timer?.invalidate()
                timer = nil
                isRunning = false
            }else {
                isRunning = true
                timer = Timer.scheduledTimer(withTimeInterval: 1.0,repeats: true){_ in
                    if timeRemaining > 0{
                        timeRemaining -= 1
                    }else {
                        timer?.invalidate()
                        isRunning = false
                    }
                }
            }
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        isRunning = false
        timeRemaining = 1500
    }
    
}
