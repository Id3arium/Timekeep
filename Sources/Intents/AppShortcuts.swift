import AppIntents

struct ChronicleShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogAppEventIntent(),
            phrases: [
                "Log app event with \(.applicationName)",
                "Track app with \(.applicationName)",
            ],
            shortTitle: "Log App Event",
            systemImageName: "clock"
        )
    }
}
