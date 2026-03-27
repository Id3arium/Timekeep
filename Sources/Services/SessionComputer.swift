import Foundation

enum SessionComputer {
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
                }
                // Same app opened again — just update the start to the new event
                currentlyOpen = (app: event.appName, event: event)
            } else {
                currentlyOpen = (app: event.appName, event: event)
            }
        }

        // Handle the last open app — stays active until next event
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

        return sessions.sorted { $0.startTime > $1.startTime }
    }
}
