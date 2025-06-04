import SwiftUI

struct SettingsView: View {
    @AppStorage("workDuration_seconds") var workDuration: Int = 25 * 60
    @AppStorage("breakDuration_seconds") var breakDuration: Int = 5 * 60
    @Environment(\.dismiss) var dismiss // 用于关闭 sheet
    
    var body: some View {
        // 为了让 NavigationStack/NavigationView 能显示标题和按钮，
        // SettingsView 内部通常也会有一个 NavigationStack 或 NavigationView
        NavigationStack {
            Form{
                Section(header: Text("Work Duration Setting")) { // 第一个设置组
                    // 1. 显示当前的专注时长 (分钟)
                    Text("Work Duration Now: \(workDuration / 60) Minutes")
                    
                    // 2. 添加 Stepper 来调整专注时长
                    Stepper(
                        "Adjust to (minutes)",                  // Stepper 的标签
                        value: $workDuration,          // 双向绑定到 workDuration (秒)
                        in: (1 * 60)...(60 * 60),      // 允许范围：1分钟到60分钟 (转换为秒)
                        step: 1 * 60                   // 步长：1分钟 (60秒)
                    )
                }
                
                Section(header: Text("Work Duration Setting")) {
                    Text("Break Duration Now: \(breakDuration / 60) Minutes")
                    Stepper(
                        "Adjust to (minutes)",
                        value: $breakDuration,
                        in: (1 * 60)...(60 * 60),
                        step: 1 * 60
                    )
                }
            }
            .navigationTitle("Setting") // 给设置页面一个标题
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { // 或者 .navigationBarTrailing
                    Button("Done") {
                        dismiss() // 点击“完成”按钮时关闭这个 sheet
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
