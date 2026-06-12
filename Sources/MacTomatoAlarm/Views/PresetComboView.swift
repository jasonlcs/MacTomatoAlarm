import SwiftUI

struct PresetComboView: View {
    @Environment(PomodoroViewModel.self) private var vm

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("組合快速啟動")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(TimerPreset.all) { preset in
                    PresetCard(
                        preset: preset,
                        isSelected: preset.id == vm.selectedPresetID,
                        disabled: vm.status == .running
                    )
                    .onTapGesture {
                        guard vm.status != .running else { return }
                        vm.applyPreset(preset)
                    }
                }
            }
        }
    }
}

struct PresetCard: View {
    let preset: TimerPreset
    let isSelected: Bool
    let disabled: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(preset.name)
                .font(.caption.weight(.semibold))
            Text("\(preset.focusMinutes)+\(preset.breakMinutes)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            isSelected
                ? Color.accentColor.opacity(0.15)
                : Color.gray.opacity(0.06)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 1.5)
        )
        .opacity(disabled ? 0.5 : 1)
    }
}
