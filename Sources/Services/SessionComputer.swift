import Foundation

enum SessionComputer {
    private static let debounceWindow: TimeInterval = 30
    private static let orphanTimeout: TimeInterval = 4 * 60 * 60

    /// Computes sessions from raw AppEvent data.
    /// Each event means "this app came to foreground." A session for app A ends
    /// when a different app B fires, or when the orphan timeout is reached.
    static func computeSessions(from events: [AppEvent]) -> [Session] {
        let sorted = events.sorted { $0.timestamp < $1.timestamp }

        var sessions: [Session] = []
        var currentlyOpen: (app: String, event: AppEvent)?

        for event in sorted {
            if let open = currentlyOpen {
                if open.app != event.appName {
                    // Different app opened — close the previous session
                    sessions.append(Session(
                        id: open.event.id,
                        appName: open.app,
                        startTime: open.event.timestamp,
                        endTime: event.timestamp,
                        isEstimated: false,
                        isActive: false
                    ))
                    currentlyOpen = (app: event.appName, event: event)
                } else {
                    // Same app fired again — could be a re-focus. Keep the original start time
                    // unless the gap is large enough to be a new session.
                    let gap = event.timestamp.timeIntervalSince(open.event.timestamp)
                    if gap > debounceWindow {
                        // Treat as a new session (implies the app was backgrounded and came back)
                        sessions.append(Session(
                            id: open.event.id,
                            appName: open.app,
                            startTime: open.event.timestamp,
                            endTime: event.timestamp,
                            isEstimated: true,
                            isActive: false
                        ))
                        currentlyOpen = (app: event.appName, event: event)
                    }
                    // If within debounce window, just ignore the duplicate
                }
            } else {
                currentlyOpen = (app: event.appName, event: event)
            }
        }

        // Handle the last open app
        if let open = currentlyOpen {
            let age = Date.now.timeIntervalSince(open.event.timestamp)
            if age > orphanTimeout {
                sessions.append(Session(
                    id: open.event.id,
                    appName: open.app,
                    startTime: open.event.timestamp,
                    endTime: nil,
                    isEstimated: true,
                    isActive: false
                ))
            } else {
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
