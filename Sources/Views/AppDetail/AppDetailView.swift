import SwiftUI
import SwiftData

struct AppDetailView: View {
    let appName: String

    @Query(sort: \AppEvent.timestamp, order: .reverse) private var events: [AppEvent]
    @State private var mode: PeriodMode = .daily
    @State private var selectedDate: Date = .now

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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PeriodNavigator(mode: $mode, selectedDate: $selectedDate)
                    .padding(.horizontal)

                HeroStatCard(
                    label: "Daily average",
                    value: TimeFormatter.format(dailyAverage),
                    percentChange: percentChange
                )

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
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }
}
