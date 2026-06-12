import SwiftUI

struct TimerView: View {
    @Environment(PomodoroViewModel.self) private var vm

    var body: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.15), lineWidth: 8)

            Circle()
                .trim(from: 0, to: vm.progress)
                .stroke(
                    AngularGradient(colors: phaseColors, center: .center),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: vm.progress)

            VStack(spacing: 4) {
                Text(vm.formattedRemaining)
                    .font(.system(size: 42, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.linear(duration: 0.15), value: vm.formattedRemaining)

                Text(vm.statusDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 170, height: 170)
    }

    private var phaseColors: [Color] {
        switch vm.phase {
        case .focus: return [.red, .orange]
        case .shortBreak: return [.green, .mint]
        case .longBreak: return [.blue, .teal]
        }
    }
}
