import SwiftUI
import Charts

struct UsageBarChart: View {
    let mode: PeriodMode
    let hourlyData: [Int: TimeInterval]
    let dailyData: [Int: TimeInterval]
    var accentColor: Color = .blue

    var body: some View {
        Chart {
            switch mode {
            case .daily:
                ForEach(0..<24, id: \.self) { hour in
                    let minutes = (hourlyData[hour] ?? 0) / 60
                    BarMark(
                        x: .value("Hour", hourLabel(hour)),
                        y: .value("Minutes", minutes)
                    )
                    .foregroundStyle(isCurrentHour(hour) ? accentColor.opacity(0.4) : accentColor)
                }
            case .weekly:
                ForEach(weekdayEntries, id: \.weekday) { entry in
                    let minutes = entry.time / 60
                    BarMark(
                        x: .value("Day", entry.label),
                        y: .value("Minutes", minutes)
                    )
                    .foregroundStyle(isToday(entry.weekday) ? accentColor.opacity(0.4) : accentColor)
                }

                if let avg = weeklyAverage {
                    RuleMark(y: .value("Average", avg / 60))
                        .foregroundStyle(.secondary)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let minutes = value.as(Double.self) {
                        Text(formatAxisLabel(minutes))
                            .font(.caption2)
                    }
                }
            }
        }
        .frame(height: 180)
    }

    private func hourLabel(_ hour: Int) -> String {
        if hour == 0 { return "12a" }
        if hour < 12 { return "\(hour)a" }
        if hour == 12 { return "12p" }
        return "\(hour - 12)p"
    }

    private func isCurrentHour(_ hour: Int) -> Bool {
        Calendar.current.component(.hour, from: .now) == hour
    }

    private func isToday(_ weekday: Int) -> Bool {
        Calendar.current.component(.weekday, from: .now) == weekday
    }

    private struct WeekdayEntry {
        let weekday: Int
        let label: String
        let time: TimeInterval
    }

    private var weekdayEntries: [WeekdayEntry] {
        let labels = ["S", "M", "T", "W", "T", "F", "S"]
        return (1...7).map { day in
            WeekdayEntry(
                weekday: day,
                label: labels[day - 1],
                time: dailyData[day] ?? 0
            )
        }
    }

    private var weeklyAverage: TimeInterval? {
        let values = weekdayEntries.map(\.time).filter { $0 > 0 }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private func formatAxisLabel(_ minutes: Double) -> String {
        if minutes >= 60 {
            return "\(Int(minutes / 60))h"
        }
        return "\(Int(minutes))m"
    }
}
