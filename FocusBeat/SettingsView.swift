import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss // 用于关闭 sheet
    
    var body: some View {
        // 为了让 NavigationStack/NavigationView 能显示标题和按钮，
        // SettingsView 内部通常也会有一个 NavigationStack 或 NavigationView
        NavigationStack {
            VStack {
                Text("设置选项会在这里")
                    .padding()
                Spacer()
            }
            .navigationTitle("Setting") // 给设置页面一个标题
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { // 或者 .navigationBarTrailing
                    Button("完成") {
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
