import SwiftUI

struct SettingsView: View {
    @Environment(PomodoroViewModel.self) private var vm
    @State private var focusMin: Int
    @State private var breakMin: Int
    @State private var longBreakMin: Int
    @State private var autoNext: Bool
    @State private var sound: String

    init() {
        let defaults = UserDefaults.standard
        _focusMin = State(initialValue: defaults.object(forKey: "focusMinutes") as? Int ?? 25)
        _breakMin = State(initialValue: defaults.object(forKey: "breakMinutes") as? Int ?? 5)
        _longBreakMin = State(initialValue: defaults.object(forKey: "longBreakMinutes") as? Int ?? 15)
        _autoNext = State(initialValue: defaults.bool(forKey: "autoStartNext"))
        _sound = State(initialValue: defaults.string(forKey: "selectedSound") ?? "Tink")
    }

    var body: some View {
        Form {
            Section("計時設定") {
                Picker("專注時間", selection: $focusMin) {
                    ForEach([5, 10, 15, 20, 25, 30, 45, 60, 90], id: \.self) {
                        Text("\($0) 分鐘").tag($0)
                    }
                }
                Picker("短休息時間", selection: $breakMin) {
                    ForEach([1, 3, 5, 10, 15, 20, 30], id: \.self) {
                        Text("\($0) 分鐘").tag($0)
                    }
                }
                Picker("長休息時間", selection: $longBreakMin) {
                    ForEach([5, 10, 15, 20, 25, 30, 45], id: \.self) {
                        Text("\($0) 分鐘").tag($0)
                    }
                }
            }

            Section("行為") {
                Toggle("自動開始下一階段", isOn: $autoNext)
            }

            Section("通知") {
                Picker("提示音效", selection: $sound) {
                    Text("Tink").tag("Tink")
                    Text("Basso").tag("Basso")
                    Text("Funk").tag("Funk")
                    Text("Pop").tag("Pop")
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 380, height: 320)
        .onDisappear {
            let defaults = UserDefaults.standard
            defaults.set(focusMin, forKey: "focusMinutes")
            defaults.set(breakMin, forKey: "breakMinutes")
            defaults.set(longBreakMin, forKey: "longBreakMinutes")
            defaults.set(autoNext, forKey: "autoStartNext")
            defaults.set(sound, forKey: "selectedSound")
            vm.loadSettings()
        }
    }
}
