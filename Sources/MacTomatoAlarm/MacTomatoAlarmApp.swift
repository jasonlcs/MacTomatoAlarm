import SwiftUI

@main
struct MacTomatoAlarmApp: App {
    @State private var vm = PomodoroViewModel()

    init() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            await UpdateChecker.shared.autoCheckIfNeeded()
        }
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environment(vm)
        } label: {
            Image(nsImage: MenuBarLabelRenderer.render(
                symbolName: vm.menuBarSymbol,
                text: (vm.status == .running || vm.status == .completed) ? vm.menuBarMinutes : nil,
                color: vm.menuBarPillColor
            ))
            .renderingMode(.original)
            .help(vm.menuBarTooltip)
        }
        .menuBarExtraStyle(.window)

        Window("偏好設定", id: "settings") {
            SettingsView()
                .environment(vm)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
