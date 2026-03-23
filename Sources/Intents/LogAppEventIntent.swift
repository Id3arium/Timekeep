import AppIntents
import SwiftData

struct LogAppEventIntent: AppIntent {
    static var title: LocalizedStringResource = "Log App Event"
    static var description: IntentDescription = "Records that an app was opened, for screen time tracking"

    @Parameter(title: "App Name")
    var appName: String

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$appName) was opened")
    }

    func perform() async throws -> some IntentResult {
        let appName = appName.trimmingCharacters(in: .whitespaces)
        guard !appName.isEmpty else { return .result() }

        let container = try ModelContainer(for: AppEvent.self)
        let context = ModelContext(container)
        let event = AppEvent(appName: appName, timestamp: .now)
        context.insert(event)
        try context.save()

        // Fetch app icon in background if we don't have one yet
        await AppIconFetcher.shared.fetchIfNeeded(appName: appName)

        return .result()
    }
}
