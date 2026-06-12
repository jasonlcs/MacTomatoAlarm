import SwiftUI

struct MenuBarContentView: View {
    @Environment(PomodoroViewModel.self) private var vm
    @Environment(\.openWindow) private var openWindow
    @State private var popoverWindow: NSWindow?

    var body: some View {
        VStack(spacing: 0) {
            headerView

            TimerView()
                .padding(.vertical, 12)

            PresetComboView()
                .padding(.bottom, 8)

            if vm.status == .idle || vm.status == .completed {
                QuickTimePicker()
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Divider()
                .padding(.vertical, 6)

            ControlsView()
        }
        .padding()
        .frame(width: 270)
        .onAppear {
            vm.loadSettings()
            Task { await NotificationService.shared.requestAuthorization() }
            DispatchQueue.main.async {
                popoverWindow = NSApp.keyWindow
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissPopover)) { _ in
            popoverWindow?.close()
        }
    }

    private var headerView: some View {
        HStack(spacing: 6) {
            Text(vm.phaseIcon)
            Text(vm.phaseName)
                .font(.headline)
            Spacer()
            tomatoBadge
            Button {
                popoverWindow?.close()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    openWindow(id: "settings")
                }
            } label: {
                Image(systemName: "gearshape")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("偏好設定")
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("離開")
        }
    }

    private var tomatoBadge: some View {
        HStack(spacing: 2) {
            let display = min(vm.completedSessions % 4, 4)
            ForEach(0..<display, id: \.self) { _ in
                Text("🍅")
                    .font(.caption2)
            }
        }
    }
}
