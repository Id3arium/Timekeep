import AppIntents
import SwiftData

struct LogAppEventIntent: AppIntent {
    static var title: LocalizedStringResource = "Log App Event"
    static var description: IntentDescription = "Records when an app is opened or closed for screen time tracking"

    @Parameter(title: "App Name")
    var appName: String

    @Parameter(title: "Event Type")
    var eventType: EventType

    func perform() async throws -> some IntentResult {
        let container = try ModelContainer(for: AppEvent.self)
        let context = ModelContext(container)
        let event = AppEvent(appName: appName, eventType: eventType, timestamp: .now)
        context.insert(event)
        try context.save()
        return .result()
    }
}
