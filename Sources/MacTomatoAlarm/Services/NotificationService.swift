import UserNotifications

struct NotificationService {
    static let shared = NotificationService()

    private func isRunningInAppBundle() -> Bool {
        let url = Bundle.main.bundleURL
        return url.pathExtension == "app" || url.pathExtension == "appex"
    }

    enum NotificationError: Error {
        case notAuthorized
    }

    /// Requests authorization for alerts and sounds. Returns true if granted.
    @discardableResult
    func requestAuthorization() async -> Bool {
        guard isRunningInAppBundle() else {
            #if DEBUG
            print("[NotificationService] Skipping authorization request: not running in an app bundle (\(Bundle.main.bundleURL))")
            #endif
            return false
        }
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            return granted
        } catch {
            #if DEBUG
            print("[NotificationService] Authorization request failed: \(error)")
            #endif
            return false
        }
    }

    /// Ensures notification authorization is granted. Attempts to request if not determined.
    private func ensureAuthorization() async -> Bool {
        guard isRunningInAppBundle() else { return false }
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return await requestAuthorization()
        default:
            return false
        }
    }

    /// Sends a local notification for the given phase.
    /// - Parameters:
    ///   - phase: The timer phase to notify for.
    ///   - delay: Optional delay (in seconds). If provided, schedules a time-based trigger; otherwise sends immediately.
    /// - Returns: Bool indicating whether the notification was scheduled successfully.
    @discardableResult
    func sendNotification(phase: TimerPhase, delay: TimeInterval? = nil) async -> Bool {
        guard isRunningInAppBundle() else {
            #if DEBUG
            print("[NotificationService] Skipping scheduling: not running in an app bundle (\(Bundle.main.bundleURL))")
            #endif
            return false
        }
        // Check/obtain authorization first
        guard await ensureAuthorization() else {
            #if DEBUG
            print("[NotificationService] Cannot schedule notification: not authorized")
            #endif
            return false
        }

        let content = UNMutableNotificationContent()
        switch phase {
        case .focus:
            content.title = "🍅 專注完成！"
            content.body = "做得很好，休息一下吧！"
        case .shortBreak:
            content.title = "🧘 休息結束"
            content.body = "準備好開始下一輪專注了嗎？"
        case .longBreak:
            content.title = "🌿 長休息結束"
            content.body = "充飽電了，開始新的循環吧！"
        }
        content.sound = .default

        let trigger: UNNotificationTrigger?
        if let delay, delay > 0 {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        } else {
            trigger = nil // deliver immediately
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            return true
        } catch {
            #if DEBUG
            print("[NotificationService] Failed to schedule notification: \(error)")
            #endif
            return false
        }
    }
}
