import Foundation

enum DateHelpers {
    static func startOfDay(_ date: Date = .now) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    static func endOfDay(_ date: Date = .now) -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay(date))!
    }

    static func startOfWeek(_ date: Date = .now) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components)!
    }

    static func endOfWeek(_ date: Date = .now) -> Date {
        Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek(date))!
    }

    /// "Today — Mar 22", "Yesterday — Mar 21", "Monday — Mar 20", or "Mar 19"
    static func sectionHeader(for date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let dateStr = formatter.string(from: date)

        if calendar.isDateInToday(date) {
            return "Today — \(dateStr)"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday — \(dateStr)"
        } else {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return "\(dayFormatter.string(from: date)) — \(dateStr)"
        }
    }

    /// Navigates a date by offset days
    static func offsetDay(_ date: Date, by offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: date)!
    }

    /// Navigates a date by offset weeks
    static func offsetWeek(_ date: Date, by offset: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: offset, to: date)!
    }

    /// Label for a day period: "Today", "Yesterday", or "Mar 22"
    static func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    /// Label for a week period: "This week", "Last week", or "Mar 10 – 16"
    static func weekLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date.now
        let thisWeekStart = startOfWeek(now)
        let targetWeekStart = startOfWeek(date)

        if calendar.isDate(targetWeekStart, inSameDayAs: thisWeekStart) {
            return "This week"
        } else if let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart),
                  calendar.isDate(targetWeekStart, inSameDayAs: lastWeek) {
            return "Last week"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: targetWeekStart)
            let end = formatter.string(from: calendar.date(byAdding: .day, value: 6, to: targetWeekStart)!)
            return "\(start) – \(end)"
        }
    }
}
