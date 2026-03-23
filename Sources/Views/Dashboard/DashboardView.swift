import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \AppEvent.timestamp, order: .reverse) private var events: [AppEvent]
    @State private var mode: PeriodMode = .daily
    @State private var selectedDate: Date = .now

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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PeriodNavigator(mode: $mode, selectedDate: $selectedDate)
                    .padding(.horizontal)

                HeroStatCard(
                    label: "Total screen time",
                    value: TimeFormatter.format(stats.totalScreenTime)
                )

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
}
