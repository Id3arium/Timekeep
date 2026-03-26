import Foundation

enum SessionComputer {
    private static let debounceWindow: TimeInterval = 60
    private static let minSessionDuration: TimeInterval = 60

    /// Computes sessions from raw AppEvent data.
    /// Events with eventType "opened" start sessions; "closed" events end them explicitly.
    /// When no close event exists, sessions end when a different app opens (inferred).
    static func computeSessions(from events: [AppEvent]) -> [Session] {
        let sorted = events.sorted { $0.timestamp < $1.timestamp }

        var sessions: [Session] = []
        var currentlyOpen: (app: String, event: AppEvent)?

        for event in sorted {
            if event.eventType == "closed" {
                // Explicit close event
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
                // Ignore close events for apps that aren't currently open
                continue
            }

            // "opened" event
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
                    // Same app fired again
                    let gap = event.timestamp.timeIntervalSince(open.event.timestamp)
                    if gap > debounceWindow {
                        // Treat as a new session
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
                    // If within debounce window, ignore the duplicate
                }
            } else {
                currentlyOpen = (app: event.appName, event: event)
            }
        }

        // Handle the last open app — stays active forever until next event
        if let open = currentlyOpen {
            sessions.append(Session(
                id: open.event.id,
                appName: open.app,
                startTime: open.event.timestamp,
                endTime: nil,
                isEstimated: false,
                isActive: true
            ))
        }

        // Post-processing: drop short sessions, then merge adjacent same-app sessions
        let filtered = sessions.filter { session in
            // Keep active sessions and sessions >= minimum duration
            session.isActive || (session.duration ?? 0) >= minSessionDuration
        }

        return mergeSessions(filtered)
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
