import Foundation
import SwiftData

@Model
final class AppEvent {
    var id: UUID
    var appName: String
    var timestamp: Date

    init(appName: String, timestamp: Date = .now) {
        self.id = UUID()
        self.appName = appName
        self.timestamp = timestamp
    }
}
