import SwiftUI

struct QuickTimePicker: View {
    @Environment(PomodoroViewModel.self) private var vm

    private let focusOptions = [15, 20, 25, 30, 45, 60]
    private let breakOptions = [3, 5, 10, 15, 20, 30]

    var body: some View {
        @Bindable var bvm = vm

        return VStack(spacing: 6) {
            pillRow(title: "專注", options: focusOptions, selection: $bvm.quickFocusMinutes)
            pillRow(title: "休息", options: breakOptions, selection: $bvm.quickBreakMinutes)
        }
    }

    private func pillRow(title: String, options: [Int], selection: Binding<Int>) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(options, id: \.self) { value in
                        Button {
                            selection.wrappedValue = value
                        } label: {
                            Text("\(value)")
                                .font(.caption2.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(selection.wrappedValue == value ? Color.accentColor : Color.gray.opacity(0.1))
                                .foregroundStyle(selection.wrappedValue == value ? .white : .primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollDisabled(true)
        }
    }
}
