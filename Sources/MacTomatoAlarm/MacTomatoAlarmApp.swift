import SwiftUI

@main
struct MacTomatoAlarmApp: App {
    @State private var vm = PomodoroViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environment(vm)
        } label: {
            HStack(alignment: .center, spacing: 4) {
                Image(nsImage: menuBarImage(for: vm.menuBarIcon))
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                if vm.status == .running || vm.status == .completed {
                    Text(vm.menuBarMinutes)
                        .font(.system(.body, design: .monospaced))
                        .contentTransition(.numericText(countsDown: true))
                }
            }
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

    private func menuBarImage(for name: String) -> NSImage {
        Bundle.module.image(forResource: name) ?? NSImage(systemSymbolName: "timer", accessibilityDescription: nil)!
    }
}
