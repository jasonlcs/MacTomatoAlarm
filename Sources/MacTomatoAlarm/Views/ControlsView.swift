import SwiftUI

struct ControlsView: View {
    @Environment(PomodoroViewModel.self) private var vm

    var body: some View {
        HStack(spacing: 12) {
            Button(action: vm.toggleStartPause) {
                Label(vm.mainButtonTitle, systemImage: vm.mainButtonIcon)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(buttonColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            if vm.status == .running || vm.status == .paused {
                Button(action: vm.skip) {
                    Label("跳過", systemImage: "forward.fill")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                Button(action: vm.reset) {
                    Label("重置", systemImage: "arrow.counterclockwise")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var buttonColor: Color {
        switch vm.phase {
        case .focus: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
}
