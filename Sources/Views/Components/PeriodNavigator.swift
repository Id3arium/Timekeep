import SwiftUI

enum PeriodMode: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
}

struct PeriodNavigator: View {
    @Binding var mode: PeriodMode
    @Binding var selectedDate: Date

    var body: some View {
        VStack(spacing: 12) {
            Picker("Period", selection: $mode) {
                ForEach(PeriodMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Button {
                    navigate(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                }

                Spacer()

                Text(periodLabel)
                    .font(.subheadline.weight(.medium))

                Spacer()

                Button {
                    navigate(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                }
                .disabled(isCurrentPeriod)
            }
            .padding(.horizontal, 4)
        }
    }

    private var periodLabel: String {
        switch mode {
        case .daily: DateHelpers.dayLabel(for: selectedDate)
        case .weekly: DateHelpers.weekLabel(for: selectedDate)
        }
    }

    private var isCurrentPeriod: Bool {
        let calendar = Calendar.current
        switch mode {
        case .daily:
            return calendar.isDateInToday(selectedDate)
        case .weekly:
            return calendar.isDate(
                DateHelpers.startOfWeek(selectedDate),
                inSameDayAs: DateHelpers.startOfWeek(.now)
            )
        }
    }

    private func navigate(by offset: Int) {
        withAnimation {
            switch mode {
            case .daily:
                selectedDate = DateHelpers.offsetDay(selectedDate, by: offset)
            case .weekly:
                selectedDate = DateHelpers.offsetWeek(selectedDate, by: offset)
            }
        }
    }
}
