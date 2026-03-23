import AppIntents
import SwiftData

struct LogAppEventIntent: AppIntent {
    static var title: LocalizedStringResource = "Log App Event"
    static var description: IntentDescription = "Records that an app was opened, for screen time tracking"

    @Parameter(title: "App")
    var app: TrackedAppEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$app) was opened")
    }

    func perform() async throws -> some IntentResult {
        let container = try ModelContainer(for: AppEvent.self)
        let context = ModelContext(container)
        let event = AppEvent(appName: app.name, timestamp: .now)
        context.insert(event)
        try context.save()
        return .result()
    }
}
