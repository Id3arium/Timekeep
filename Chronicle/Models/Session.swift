import Foundation

struct Session: Identifiable {
    let id: UUID
    let appName: String
    let startTime: Date
    let endTime: Date?
    let isEstimated: Bool
    let isActive: Bool

    var duration: TimeInterval? {
        guard let endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
}
