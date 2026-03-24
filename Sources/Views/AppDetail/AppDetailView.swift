import SwiftUI
import SwiftData

struct AppDetailView: View {
    let appName: String

    @Query(sort: \AppEvent.timestamp, order: .forward) private var events: [AppEvent]
    @State private var mode: PeriodMode = .daily
    @State private var selectedDate: Date = .now
    private var earliestDate: Date? {
        events.first?.timestamp
    }

    private var allSessions: [Session] {
        SessionComputer.computeSessions(from: Array(events))
    }

    private var appSessions: [Session] {
        StatsCalculator.sessions(for: appName, in: allSessions)
    }

    private var periodSessions: [Session] {
        switch mode {
        case .daily:
            StatsCalculator.sessions(for: selectedDate, in: appSessions)
        case .weekly:
            StatsCalculator.sessions(forWeekOf: selectedDate, in: appSessions)
        }
    }

    private var previousPeriodSessions: [Session] {
        switch mode {
        case .daily:
            let prevDate = DateHelpers.offsetDay(selectedDate, by: -1)
            return StatsCalculator.sessions(for: prevDate, in: appSessions)
        case .weekly:
            let prevDate = DateHelpers.offsetWeek(selectedDate, by: -1)
            return StatsCalculator.sessions(forWeekOf: prevDate, in: appSessions)
        }
    }

    private var stats: PeriodStats {
        StatsCalculator.stats(for: periodSessions)
    }

    private var appColor: Color {
        ColorGenerator.color(for: appName)
    }

    private var dailyAverage: TimeInterval {
        let days = mode == .daily ? 1 : 7
        return StatsCalculator.dailyAverage(totalTime: stats.totalScreenTime, days: days)
    }

    private var percentChange: Double? {
        let prevStats = StatsCalculator.stats(for: previousPeriodSessions)
        return StatsCalculator.percentChange(
            current: stats.totalScreenTime,
            previous: prevStats.totalScreenTime
        )
    }

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

                    Text(TimeFormatter.format(dailyAverage))
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    if let change = percentChange {
                        let isUp = change > 0
                        HStack(spacing: 2) {
                            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption2)
                            Text("\(abs(Int(change)))% from last period")
                                .font(.caption)
                        }
                        .foregroundStyle(isUp ? .red : .green)
                    }
                }

                UsageBarChart(
                    mode: mode,
                    hourlyData: stats.hourlyBreakdown,
                    dailyData: stats.dailyBreakdown,
                    accentColor: appColor
                )
                .padding(.horizontal)

                // Summary cards
                HStack(spacing: 12) {
                    summaryCard(
                        label: "Total time",
                        value: TimeFormatter.format(stats.totalScreenTime)
                    )
                    summaryCard(
                        label: "Sessions",
                        value: "\(periodSessions.count)"
                    )
                    summaryCard(
                        label: "Avg session",
                        value: averageSessionText
                    )
                }
                .padding(.horizontal)

                // Sessions list
                if !todaySessions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(sessionsHeaderText)
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        ForEach(todaySessions) { session in
                            SessionRow(session: session, color: appColor)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(appName)
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

    private var todaySessions: [Session] {
        let daySessions: [Session]
        switch mode {
        case .daily:
            daySessions = periodSessions
        case .weekly:
            daySessions = StatsCalculator.sessions(for: .now, in: appSessions)
        }
        return daySessions.sorted { $0.startTime > $1.startTime }
    }

    private var sessionsHeaderText: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today's sessions"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: selectedDate)) sessions"
        }
    }

    private var averageSessionText: String {
        guard !periodSessions.isEmpty else { return "—" }
        let total = periodSessions.compactMap(\.duration).reduce(0, +)
        let avg = total / Double(periodSessions.count)
        return TimeFormatter.format(avg)
    }

    private func summaryCard(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.weight(.semibold))
            Text(label)
                .font(.caption)
                .foregroundStyle(ColorGenerator.subtitleColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }
}
