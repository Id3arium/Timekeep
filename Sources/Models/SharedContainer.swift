import SwiftData

enum SharedContainer {
    static func make() throws -> ModelContainer {
        try ModelContainer(for: AppEvent.self)
    }
}
