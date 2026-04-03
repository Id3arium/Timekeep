import AppIntents
import SwiftData

struct LogAppEventIntent: AppIntent {
    static var title: LocalizedStringResource = "Log App Event"
    static var description: IntentDescription = "Records that an app was opened or closed, for screen time tracking"

    @Parameter(title: "App Name")
    var appName: String

    @Parameter(title: "Event Type")
    var eventType: EventType

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$appName) \(\.$eventType)")
    }

    func perform() async throws -> some IntentResult {
        let appName = appName.trimmingCharacters(in: .whitespaces)
        guard !appName.isEmpty else { return .result() }

        let container = try SharedContainer.make()
        let context = ModelContext(container)
        let event = AppEvent(appName: appName, eventType: eventType.rawValue, timestamp: .now)
        context.insert(event)
        try context.save()

        // Fetch app icon in background only on open events
        if eventType == .opened {
            await AppIconFetcher.shared.fetchIfNeeded(appName: appName)
        }

        return .result()
    }
}
