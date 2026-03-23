import Foundation
import SwiftData

@Model
final class AppEvent {
    var id: UUID
    var appName: String
    var eventType: EventType
    var timestamp: Date

    init(appName: String, eventType: EventType, timestamp: Date = .now) {
        self.id = UUID()
        self.appName = appName
        self.eventType = eventType
        self.timestamp = timestamp
    }
}
