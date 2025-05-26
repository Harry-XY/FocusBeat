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
            Text(formatTime(timeRemaining))
                .font(.system(size: 64, weight:  .bold, design: .monospaced))
            
            Button {
                
            }label: {
                Text(isRunning ? "Pause" : "Start")
                    .padding()
                    .frame(width: 100)
                    .background(isRunning ? Color.red : Color.green)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            
            
            
        }
        .padding()
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
    
    
}
