import AppIntents

/// An entity representing an app name for use in Shortcuts.
/// This gives the Shortcuts UI a picker instead of a free-text field.
struct TrackedAppEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "App"

    static var defaultQuery = TrackedAppQuery()

    var id: String  // The app name itself is the ID
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    init(name: String) {
        self.id = name
        self.name = name
    }
}

struct TrackedAppQuery: EntityStringQuery {
    private static let allApps: [TrackedAppEntity] = {
        CuratedApps.all.map { TrackedAppEntity(name: $0.name) }
    }()

    /// Returns entities for the given identifiers
    func entities(for identifiers: [String]) async throws -> [TrackedAppEntity] {
        identifiers.map { TrackedAppEntity(name: $0) }
    }

    /// Called when the user types into the search field in the Shortcuts picker
    func entities(matching string: String) async throws -> [TrackedAppEntity] {
        if string.isEmpty {
            return Self.allApps
        }
        let filtered = Self.allApps.filter { $0.name.localizedCaseInsensitiveContains(string) }
        // If no match, let them use what they typed as a custom app name
        if filtered.isEmpty {
            return [TrackedAppEntity(name: string)]
        }
        return filtered
    }

    /// The list shown by default when the picker opens
    func suggestedEntities() async throws -> [TrackedAppEntity] {
        Self.allApps
    }
}
