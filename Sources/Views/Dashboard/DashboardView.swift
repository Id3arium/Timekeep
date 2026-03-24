import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \AppEvent.timestamp, order: .forward) private var events: [AppEvent]
    @State private var mode: PeriodMode = .daily
    @State private var selectedDate: Date = .now
    private var earliestDate: Date? {
        events.first?.timestamp
    }

    private var allSessions: [Session] {
        SessionComputer.computeSessions(from: Array(events))
    }

    private var periodSessions: [Session] {
        switch mode {
        case .daily:
            StatsCalculator.sessions(for: selectedDate, in: allSessions)
        case .weekly:
            StatsCalculator.sessions(forWeekOf: selectedDate, in: allSessions)
        }
    }

    private var stats: PeriodStats {
        StatsCalculator.stats(for: periodSessions)
    }

    /// Full date label shown above the chart, like Apple's "Sunday, January 9"
    private var chartDateLabel: String {
        switch mode {
        case .daily:
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d"
            return formatter.string(from: selectedDate)
        case .weekly:
            let start = DateHelpers.startOfWeek(selectedDate)
            let end = Calendar.current.date(byAdding: .day, value: 6, to: start)!
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Segmented control always visible
                Picker("Period", selection: $mode) {
                    ForEach(PeriodMode.allCases, id: \.self) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                dateNavigator
                    .padding(.horizontal)

                // Chart date label + hero stat
                VStack(spacing: 4) {
                    Text(chartDateLabel)
                        .font(.subheadline)
                        .foregroundStyle(ColorGenerator.subtitleColor)

                    Text(TimeFormatter.format(stats.totalScreenTime))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }

                UsageBarChart(
                    mode: mode,
                    hourlyData: stats.hourlyBreakdown,
                    dailyData: stats.dailyBreakdown,
                    accentColor: .blue
                )
                .padding(.horizontal)

                if !stats.appBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Most used")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        let maxTime = stats.appBreakdown.first?.totalTime ?? 1

                        ForEach(stats.appBreakdown) { appStats in
                            NavigationLink(value: appStats.appName) {
                                AppUsageRow(stats: appStats, maxTime: maxTime)
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("All apps")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var dateNavigator: some View {
        HStack {
            Button {
                navigate(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
            }
            .disabled(isEarliestPeriod)

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

    private var isEarliestPeriod: Bool {
        guard let earliest = earliestDate else { return true }
        let calendar = Calendar.current
        switch mode {
        case .daily:
            return calendar.isDate(selectedDate, inSameDayAs: earliest)
                || selectedDate < earliest
        case .weekly:
            return DateHelpers.startOfWeek(selectedDate) <= DateHelpers.startOfWeek(earliest)
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
