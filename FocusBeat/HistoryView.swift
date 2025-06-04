//
//  HistoryView.swift
//  FocusBeat
//
//  Created by Harry Geng on 2025/06/04.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss // 用于关闭 sheet
    
    var body: some View {
        NavigationStack { // 或者 NavigationView
            VStack {
                Text("番茄钟历史记录将会显示在这里")
                    .padding()
                Spacer()
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // 或者 .topBarTrailing
                    Button("Done") {
                        dismiss() // 点击“完成”关闭 sheet
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryView()
}
