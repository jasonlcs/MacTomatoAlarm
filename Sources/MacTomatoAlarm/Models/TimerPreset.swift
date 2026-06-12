import Foundation

struct TimerPreset: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var focusMinutes: Int
    var breakMinutes: Int
    var longBreakMinutes: Int

    static let classic = TimerPreset(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
        name: "經典",
        focusMinutes: 25,
        breakMinutes: 5,
        longBreakMinutes: 15
    )

    static let longFocus = TimerPreset(
        id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
        name: "長專注",
        focusMinutes: 50,
        breakMinutes: 10,
        longBreakMinutes: 20
    )

    static let sprint = TimerPreset(
        id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
        name: "衝刺",
        focusMinutes: 15,
        breakMinutes: 5,
        longBreakMinutes: 15
    )

    static let custom = TimerPreset(
        id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
        name: "自訂",
        focusMinutes: 25,
        breakMinutes: 5,
        longBreakMinutes: 15
    )

    static let all: [TimerPreset] = [.classic, .longFocus, .sprint, .custom]
}
