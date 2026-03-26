import AppIntents

enum EventType: String, Codable, AppEnum {
    case opened
    case closed

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Event Type"
    }

    static var caseDisplayRepresentations: [EventType: DisplayRepresentation] {
        [
            .opened: "Opened",
            .closed: "Closed",
        ]
    }
}
