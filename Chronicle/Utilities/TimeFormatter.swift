import Foundation

enum TimeFormatter {
    /// Formats a TimeInterval as a human-readable duration.
    /// Examples: "2h 34m", "45m", "< 1m"
    static func format(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "< 1m"
        }
    }

    /// Formats a Date as a time string like "10:42 PM"
    static func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    /// Formats a time range like "9:28 — 10:15 PM"
    static func timeRange(from start: Date, to end: Date) -> String {
        let startFormatter = DateFormatter()
        let endFormatter = DateFormatter()

        let calendar = Calendar.current
        let startPeriod = calendar.component(.hour, from: start) >= 12 ? "PM" : "AM"
        let endPeriod = calendar.component(.hour, from: end) >= 12 ? "PM" : "AM"

        if startPeriod == endPeriod {
            startFormatter.dateFormat = "h:mm"
        } else {
            startFormatter.dateFormat = "h:mm a"
        }
        endFormatter.dateFormat = "h:mm a"

        return "\(startFormatter.string(from: start)) — \(endFormatter.string(from: end))"
    }
}
