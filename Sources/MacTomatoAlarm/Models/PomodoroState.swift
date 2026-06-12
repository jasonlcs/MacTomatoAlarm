enum TimerStatus: String, Codable, Equatable, Sendable {
    case idle
    case running
    case paused
    case completed
}
