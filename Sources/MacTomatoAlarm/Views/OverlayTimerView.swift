import SwiftUI

struct OverlayTimerView: View {
    let text: String
    let phase: TimerPhase

    var body: some View {
        HStack(spacing: 12) {
            Text(phase.icon)
                .font(.system(size: 40))
            Text(text)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(borderColor, lineWidth: 3)
        )
        .shadow(radius: 6)
    }

    private var borderColor: Color {
        switch phase {
        case .focus: return .orange
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
}

