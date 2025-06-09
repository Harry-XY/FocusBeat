import SwiftUI

struct SettingsView: View {
    @AppStorage("workDuration_seconds") var workDuration: Int = 25 * 60
    @AppStorage("breakDuration_seconds") var breakDuration: Int = 5 * 60
    @Environment(\.dismiss) var dismiss // 用于关闭 sheet
    
    private var workMinutesBinding: Binding<Int> {
        Binding<Int>(
            get: {
                // 当 Picker 读取值时，这个闭包被调用
                // 我们将存储的秒数转换为分钟
                return self.workDuration / 60
            },
            set: { newMinutes in
                // 当用户在 Picker 中选择了新的分钟数时，这个闭包被调用
                // 我们将新的分钟数转换为秒，并存回 @AppStorage 变量
                self.workDuration = newMinutes * 60
            }
        )
    }
    
    private var breakMinutesBinding: Binding<Int> {
        Binding<Int>(
            get: {
                // 当 Picker 读取值时，这个闭包被调用
                // 我们将存储的秒数转换为分钟
                return self.breakDuration / 60
            },
            set: { newMinutes in
                // 当用户在 Picker 中选择了新的分钟数时，这个闭包被调用
                // 我们将新的分钟数转换为秒，并存回 @AppStorage 变量
                self.breakDuration = newMinutes * 60
            }
        )
    }
    
    var body: some View {
        // 为了让 NavigationStack/NavigationView 能显示标题和按钮，
        // SettingsView 内部通常也会有一个 NavigationStack 或 NavigationView
        NavigationStack {
            Form{
                Section(header: Text("TIMER")) {
                    Picker("Focus Duration", selection: workMinutesBinding) { // <--- 使用我们新的 binding
                        ForEach(1...60, id: \.self) { minute in
                            Text("\(minute) minute\(minute == 1 ? "" : "s")").tag(minute)
                        }
                    }
                    .pickerStyle(.menu) // <-- 应用滚轮样式
                    
                    Picker("Break Duration", selection: breakMinutesBinding) {
                        ForEach(1...30, id: \.self) { minute in
                            Text("\(minute) minute\(minute == 1 ? "" : "s")").tag(minute)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                
                Section {
                    Button("Restore Defaults", role: .destructive) {
                        workDuration = 25 * 60  // <-- 恢复默认的动作
                        breakDuration = 5 * 60
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Settings") // 给设置页面一个标题
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
