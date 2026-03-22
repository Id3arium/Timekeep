import Foundation

enum SessionComputer {
    private static let debounceWindow: TimeInterval = 30
    private static let orphanTimeout: TimeInterval = 4 * 60 * 60

    /// Computes sessions from raw AppEvent data.
    /// Events should span the full date range of interest plus some buffer before/after
    /// to correctly handle sessions that cross boundaries.
    static func computeSessions(from events: [AppEvent]) -> [Session] {
        let sorted = events.sorted { $0.timestamp < $1.timestamp }

        var sessions: [Session] = []
        var currentlyOpen: (app: String, event: AppEvent)?

        for event in sorted {
            switch event.eventType {
            case .opened:
                // If another app was open, close its session (estimated)
                if let open = currentlyOpen {
                    sessions.append(Session(
                        id: open.event.id,
                        appName: open.app,
                        startTime: open.event.timestamp,
                        endTime: event.timestamp,
                        isEstimated: true,
                        isActive: false
                    ))
                }
                currentlyOpen = (app: event.appName, event: event)

            case .closed:
                if let open = currentlyOpen, open.app == event.appName {
                    sessions.append(Session(
                        id: open.event.id,
                        appName: open.app,
                        startTime: open.event.timestamp,
                        endTime: event.timestamp,
                        isEstimated: false,
                        isActive: false
                    ))
                    currentlyOpen = nil
                }
                // Ignore orphaned close events (no matching open)
            }
        }

        // Handle currently open app (no close event yet)
        if let open = currentlyOpen {
            let age = Date.now.timeIntervalSince(open.event.timestamp)
            if age > orphanTimeout {
                // Too old — orphaned, unknown duration
                sessions.append(Session(
                    id: open.event.id,
                    appName: open.app,
                    startTime: open.event.timestamp,
                    endTime: nil,
                    isEstimated: true,
                    isActive: false
                ))
            } else {
                // Still active
                sessions.append(Session(
                    id: open.event.id,
                    appName: open.app,
                    startTime: open.event.timestamp,
                    endTime: nil,
                    isEstimated: false,
                    isActive: true
                ))
            }
        }

        return mergeSessions(sessions)
    }

    /// Merges adjacent sessions for the same app if the gap between them is < debounceWindow.
    private static func mergeSessions(_ sessions: [Session]) -> [Session] {
        let grouped = Dictionary(grouping: sessions) { $0.appName }
        var merged: [Session] = []

        for (_, appSessions) in grouped {
            let sorted = appSessions.sorted { $0.startTime < $1.startTime }
            var current: Session? = nil

            for session in sorted {
                if let prev = current {
                    let gap: TimeInterval
                    if let prevEnd = prev.endTime {
                        gap = session.startTime.timeIntervalSince(prevEnd)
                    } else {
                        gap = .infinity
                    }

                    if gap < debounceWindow && gap >= 0 {
                        // Merge: extend previous session to cover this one
                        current = Session(
                            id: prev.id,
                            appName: prev.appName,
                            startTime: prev.startTime,
                            endTime: session.endTime,
                            isEstimated: prev.isEstimated || session.isEstimated,
                            isActive: session.isActive
                        )
                    } else {
                        merged.append(prev)
                        current = session
                    }
                } else {
                    current = session
                }
            }

            if let last = current {
                merged.append(last)
            }
        }

        return merged.sorted { $0.startTime > $1.startTime }
    }
}
