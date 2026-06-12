enum TimerPhase: String, Codable, Sendable {
    case focus
    case shortBreak
    case longBreak

    var displayName: String {
        switch self {
        case .focus: return "專注"
        case .shortBreak: return "短休息"
        case .longBreak: return "長休息"
        }
    }

    var icon: String {
        switch self {
        case .focus: return "🍅"
        case .shortBreak: return "🧘"
        case .longBreak: return "🌿"
        }
    }
}
