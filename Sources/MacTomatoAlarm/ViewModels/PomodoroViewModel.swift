import SwiftUI
import Observation

extension Notification.Name {
    static let dismissPopover = Notification.Name("DismissPopover")
}

@Observable
final class PomodoroViewModel {
    // MARK: - Timer State
    var phase: TimerPhase = .focus
    var status: TimerStatus = .idle
    var timeRemaining: TimeInterval = 25 * 60
    var totalTime: TimeInterval = 25 * 60
    var completedSessions: Int = 0
    private var cycleCount: Int = 0

    // MARK: - Quick Select
    var quickFocusMinutes: Int = 25
    var quickBreakMinutes: Int = 5
    var quickLongBreakMinutes: Int = 15

    // MARK: - Preset
    var selectedPresetID: UUID = TimerPreset.classic.id

    // MARK: - Settings
    var autoStartNext: Bool = false
    var selectedSound: String = "Tink"
    var pulseIntervalMinutes: Int = 1

    private var timerTask: Task<Void, Never>?

    var onPulseTick: ((_ isPulsing: Bool, _ formatted: String, _ phase: TimerPhase) -> Void)?

    init() {
        loadSettings()
        totalTime = TimeInterval(quickFocusMinutes * 60)
        timeRemaining = totalTime
        onPulseTick = { isPulsing, formatted, phase in
            Task { @MainActor in
                if isPulsing {
                    OverlayPanelManager.shared.showOrUpdate(formatted, phase: phase)
                } else {
                    OverlayPanelManager.shared.hide()
                }
            }
        }
    }

    // MARK: - Computed

    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return 1 - (timeRemaining / totalTime)
    }

    var formattedRemaining: String {
        let totalSeconds = Int(max(timeRemaining, 0))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var menuBarMinutes: String {
        let totalSeconds = Int(max(timeRemaining, 0))
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        if totalSeconds < 60 {
            return "\(mins):\(String(format: "%02d", secs))"
        }
        return "\(mins)"
    }

    var menuBarTooltip: String {
        let totalSeconds = Int(max(timeRemaining, 0))
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return "\(phase.icon) \(phase.displayName) \(mins):\(String(format: "%02d", secs))"
    }

    var phaseIcon: String { phase.icon }
    var phaseName: String { phase.displayName }

    var selectedPreset: TimerPreset {
        TimerPreset.all.first { $0.id == selectedPresetID } ?? .classic
    }

    var menuBarIcon: String {
        switch status {
        case .running: return "MenuBar_Running"
        case .paused: return "MenuBar_Paused"
        case .idle, .completed: return "MenuBar_Stopped"
        }
    }

    var mainButtonTitle: String {
        switch status {
        case .idle: return "開始"
        case .running: return "暫停"
        case .paused: return "繼續"
        case .completed: return "下一階段"
        }
    }

    var mainButtonIcon: String {
        switch status {
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        case .idle: return "play.fill"
        case .completed: return "forward.fill"
        }
    }

    var statusDescription: String {
        switch status {
        case .idle: return "準備就緒"
        case .running: return "進行中"
        case .paused: return "已暫停"
        case .completed: return "完成！"
        }
    }

    // MARK: - Actions

    func toggleStartPause() {
        switch status {
        case .idle:
            applyQuickSettings()
            startTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                NotificationCenter.default.post(name: .dismissPopover, object: nil)
            }
        case .running:
            pauseTimer()
        case .paused:
            resumeTimer()
        case .completed:
            moveToNextPhase()
            startTimer()
        }
    }

    func skip() {
        timerTask?.cancel()
        timerTask = nil
        moveToNextPhase()
    }

    func reset() {
        timerTask?.cancel()
        timerTask = nil
        status = .idle
        phase = .focus
        cycleCount = completedSessions / 4
        totalTime = TimeInterval(quickFocusMinutes * 60)
        timeRemaining = totalTime
    }

    func applyPreset(_ preset: TimerPreset) {
        selectedPresetID = preset.id
        quickFocusMinutes = preset.focusMinutes
        quickBreakMinutes = preset.breakMinutes
        quickLongBreakMinutes = preset.longBreakMinutes
        reset()
    }

    func loadSettings() {
        let defaults = UserDefaults.standard
        quickFocusMinutes = defaults.object(forKey: "focusMinutes") as? Int ?? 25
        quickBreakMinutes = defaults.object(forKey: "breakMinutes") as? Int ?? 5
        quickLongBreakMinutes = defaults.object(forKey: "longBreakMinutes") as? Int ?? 15
        autoStartNext = defaults.bool(forKey: "autoStartNext")
        selectedSound = defaults.string(forKey: "selectedSound") ?? "Tink"
        pulseIntervalMinutes = defaults.object(forKey: "pulseIntervalMinutes") as? Int ?? 1
        if status == .idle {
            totalTime = TimeInterval(quickFocusMinutes * 60)
            timeRemaining = totalTime
        }
    }

    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(quickFocusMinutes, forKey: "focusMinutes")
        defaults.set(quickBreakMinutes, forKey: "breakMinutes")
        defaults.set(quickLongBreakMinutes, forKey: "longBreakMinutes")
        defaults.set(autoStartNext, forKey: "autoStartNext")
        defaults.set(selectedSound, forKey: "selectedSound")
        defaults.set(pulseIntervalMinutes, forKey: "pulseIntervalMinutes")
    }

    // MARK: - Private

    private func recordCompletedSession() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "completedSessions_\(today.timeIntervalSince1970)"
        let count = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(count + 1, forKey: key)
    }

    private func applyQuickSettings() {
        switch phase {
        case .focus:
            totalTime = TimeInterval(quickFocusMinutes * 60)
        case .shortBreak:
            totalTime = TimeInterval(quickBreakMinutes * 60)
        case .longBreak:
            totalTime = TimeInterval(quickLongBreakMinutes * 60)
        }
        timeRemaining = totalTime
    }

    private func startTimer() {
        status = .running
        timerTask = Task { await runTimerLoop() }
    }

    private func pauseTimer() {
        status = .paused
        timerTask?.cancel()
        timerTask = nil
    }

    private func resumeTimer() {
        status = .running
        timerTask = Task { await runTimerLoop() }
    }

    private func runTimerLoop() async {
        while timeRemaining > 0 && status == .running {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled, status == .running else { return }
            timeRemaining -= 1
            let totalSecs = Int(max(timeRemaining, 0))
            let mins = totalSecs / 60
            let secs = totalSecs % 60
            let isPulse: Bool
            if phase == .shortBreak || phase == .longBreak {
                isPulse = true
            } else {
                isPulse = secs >= 1 && secs <= 3 && mins % pulseIntervalMinutes == 0
            }
            onPulseTick?(isPulse, formattedRemaining, phase)
        }
        guard !Task.isCancelled else { return }
        await handleTimerComplete()
    }

    private func handleTimerComplete() async {
        status = .completed
        if phase == .focus {
            recordCompletedSession()
        }
        await NotificationService.shared.sendNotification(phase: phase)
        AudioService.shared.playSound(selectedSound)
        if phase == .focus || autoStartNext {
            moveToNextPhase()
            startTimer()
        }
    }

    private func moveToNextPhase() {
        switch phase {
        case .focus:
            completedSessions += 1
            cycleCount += 1
            if cycleCount % 4 == 0 {
                phase = .longBreak
                totalTime = TimeInterval(quickLongBreakMinutes * 60)
            } else {
                phase = .shortBreak
                totalTime = TimeInterval(quickBreakMinutes * 60)
            }
        case .shortBreak, .longBreak:
            phase = .focus
            totalTime = TimeInterval(quickFocusMinutes * 60)
        }
        status = .idle
        timeRemaining = totalTime
    }
}
