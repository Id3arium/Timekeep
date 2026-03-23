import Foundation

struct AppUsageStats: Identifiable {
    let id = UUID()
    let appName: String
    let totalTime: TimeInterval
    let sessionCount: Int
    let averageSessionLength: TimeInterval
}

struct PeriodStats {
    let totalScreenTime: TimeInterval
    let appBreakdown: [AppUsageStats]
    let hourlyBreakdown: [Int: TimeInterval]   // hour (0-23) → seconds
    let dailyBreakdown: [Int: TimeInterval]     // weekday (1=Sun...7=Sat) → seconds
}

enum StatsCalculator {
    /// Calculate stats for a list of sessions within a given period
    static func stats(for sessions: [Session]) -> PeriodStats {
        let totalScreenTime = sessions.compactMap(\.duration).reduce(0, +)

        // Per-app breakdown
        let grouped = Dictionary(grouping: sessions) { $0.appName }
        var appBreakdown: [AppUsageStats] = []

        for (appName, appSessions) in grouped {
            let totalTime = appSessions.compactMap(\.duration).reduce(0, +)
            let count = appSessions.count
            let avg = count > 0 ? totalTime / Double(count) : 0

            appBreakdown.append(AppUsageStats(
                appName: appName,
                totalTime: totalTime,
                sessionCount: count,
                averageSessionLength: avg
            ))
        }

        appBreakdown.sort { $0.totalTime > $1.totalTime }

        // Hourly breakdown
        let calendar = Calendar.current
        var hourly: [Int: TimeInterval] = [:]
        for session in sessions {
            guard session.duration != nil else { continue }
            let endTime = session.endTime ?? Date.now
            distributeTime(
                start: session.startTime,
                end: endTime,
                into: &hourly,
                using: { calendar.component(.hour, from: $0) }
            )
        }

        // Daily breakdown (weekday)
        var daily: [Int: TimeInterval] = [:]
        for session in sessions {
            guard let sessionDuration = session.duration else { continue }
            let weekday = calendar.component(.weekday, from: session.startTime)
            daily[weekday, default: 0] += sessionDuration
        }

        return PeriodStats(
            totalScreenTime: totalScreenTime,
            appBreakdown: appBreakdown,
            hourlyBreakdown: hourly,
            dailyBreakdown: daily
        )
    }

    /// Calculate daily average for a set of sessions over a number of days
    static func dailyAverage(totalTime: TimeInterval, days: Int) -> TimeInterval {
        guard days > 0 else { return 0 }
        return totalTime / Double(days)
    }

    /// Calculate percent change between two values
    static func percentChange(current: TimeInterval, previous: TimeInterval) -> Double? {
        guard previous > 0 else { return nil }
        return ((current - previous) / previous) * 100
    }

    /// Filter sessions for a specific app
    static func sessions(for appName: String, in sessions: [Session]) -> [Session] {
        sessions.filter { $0.appName == appName }
    }

    /// Filter sessions for a specific day
    static func sessions(for date: Date, in sessions: [Session]) -> [Session] {
        let start = DateHelpers.startOfDay(date)
        let end = DateHelpers.endOfDay(date)
        return sessions.filter { $0.startTime >= start && $0.startTime < end }
    }

    /// Filter sessions for a specific week
    static func sessions(forWeekOf date: Date, in sessions: [Session]) -> [Session] {
        let start = DateHelpers.startOfWeek(date)
        let end = DateHelpers.endOfWeek(date)
        return sessions.filter { $0.startTime >= start && $0.startTime < end }
    }

    // MARK: - Private

    /// Distributes session time across buckets (hours or days)
    private static func distributeTime(
        start: Date,
        end: Date,
        into buckets: inout [Int: TimeInterval],
        using keyExtractor: (Date) -> Int
    ) {
        let calendar = Calendar.current
        var current = start

        while current < end {
            let key = keyExtractor(current)
            let nextBoundary: Date

            // Find the start of the next hour
            var components = calendar.dateComponents([.year, .month, .day, .hour], from: current)
            components.hour! += 1
            nextBoundary = min(calendar.date(from: components) ?? end, end)

            let chunkDuration = nextBoundary.timeIntervalSince(current)
            buckets[key, default: 0] += chunkDuration
            current = nextBoundary
        }
    }
}
