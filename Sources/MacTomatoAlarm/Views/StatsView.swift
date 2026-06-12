import SwiftUI

struct StatsView: View {
    @Environment(PomodoroViewModel.self) private var vm

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text("今日蕃茄")
                .font(.title2.weight(.semibold))

            HStack(spacing: 8) {
                ForEach(0..<completedToday, id: \.self) { _ in
                    Text("🍅")
                        .font(.title)
                }
            }

            if completedToday == 0 {
                Text("今天還沒有完成任何蕃茄鐘 🫣")
                    .foregroundStyle(.secondary)
            } else {
                Text("總共完成了 \(completedToday) 個蕃茄鐘！")
                    .foregroundStyle(.secondary)
            }

            Button("關閉") {
                NSApplication.shared.keyWindow?.close()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding(40)
        .frame(width: 300)
    }

    private var completedToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "completedSessions_\(today.timeIntervalSince1970)"
        return UserDefaults.standard.integer(forKey: key)
    }
}
