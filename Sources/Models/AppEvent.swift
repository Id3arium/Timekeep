import Foundation
import SwiftData

@Model
final class AppEvent {
    var id: UUID
    var appName: String
    var eventType: String = "opened"  // "opened" or "closed"
    var timestamp: Date

    init(appName: String, eventType: String = "opened", timestamp: Date = .now) {
        self.id = UUID()
        self.appName = appName
        self.eventType = eventType
        self.timestamp = timestamp
    }
}
