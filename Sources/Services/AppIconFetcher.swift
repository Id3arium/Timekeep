import SwiftUI

@MainActor
final class AppIconFetcher: ObservableObject {
    static let shared = AppIconFetcher()

    /// In-memory cache of loaded images
    private var memoryCache: [String: UIImage] = [:]

    /// Apps we've already attempted to fetch (avoid retrying failures)
    private var attempted: Set<String> = []

    /// Known Apple apps → SF Symbol mapping (not on App Store)
    private static let sfSymbols: [String: String] = [
        "Safari": "safari.fill",
        "Mail": "envelope.fill",
        "Messages": "message.fill",
        "Calendar": "calendar",
        "Notes": "note.text",
        "Reminders": "checklist",
        "Maps": "map.fill",
        "Weather": "cloud.sun.fill",
        "Camera": "camera.fill",
        "Photos": "photo.fill",
        "Clock": "clock.fill",
        "Settings": "gear",
        "Files": "folder.fill",
        "App Store": "bag.fill",
        "Music": "music.note",
        "Podcasts": "antenna.radiowaves.left.and.right",
        "News": "newspaper.fill",
        "Health": "heart.fill",
        "Wallet": "creditcard.fill",
        "FaceTime": "video.fill",
        "Phone": "phone.fill",
        "Contacts": "person.crop.circle.fill",
        "Find My": "location.fill",
        "Shortcuts": "apps.iphone",
        "Voice Memos": "waveform",
        "Home": "house.fill",
        "Fitness": "figure.run",
        "Freeform": "scribble.variable",
        "Books": "book.fill",
        "Translate": "character.bubble.fill",
        "Calculator": "plusminus",
        "Compass": "safari",
        "Magnifier": "magnifyingglass",
        "Measure": "ruler.fill",
        "Tips": "lightbulb.fill",
    ]

    private init() {
        loadAttemptedSet()
    }

    /// Returns cached icon or nil. Triggers a background fetch if not yet attempted.
    func icon(for appName: String) -> UIImage? {
        if let cached = memoryCache[appName] {
            return cached
        }

        // Try loading from disk
        if let diskImage = loadFromDisk(appName: appName) {
            memoryCache[appName] = diskImage
            return diskImage
        }

        // Trigger fetch if we haven't tried yet
        if !attempted.contains(appName) {
            Task {
                await fetchAndCache(appName: appName)
            }
        }

        return nil
    }

    /// SF Symbol name for known Apple apps, if any
    func sfSymbol(for appName: String) -> String? {
        Self.sfSymbols[appName]
    }

    /// Force a fetch attempt (e.g. called from the intent on first event)
    func fetchIfNeeded(appName: String) async {
        guard !attempted.contains(appName) else { return }
        guard loadFromDisk(appName: appName) == nil else {
            attempted.insert(appName)
            return
        }
        await fetchAndCache(appName: appName)
    }

    // MARK: - Private

    private func fetchAndCache(appName: String) async {
        attempted.insert(appName)
        saveAttemptedSet()

        // Skip Apple apps — they use SF Symbols
        if Self.sfSymbols[appName] != nil { return }

        guard let url = searchURL(for: appName) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let result = try? JSONDecoder().decode(ITunesSearchResult.self, from: data),
                  let firstApp = result.results.first,
                  let iconURL = URL(string: firstApp.artworkUrl512 ?? firstApp.artworkUrl100) else {
                return
            }

            let (imageData, _) = try await URLSession.shared.data(from: iconURL)
            guard let image = UIImage(data: imageData) else { return }

            saveToDisk(appName: appName, data: imageData)
            memoryCache[appName] = image
        } catch {
            // Silently fail — colored square fallback is fine
        }
    }

    private func searchURL(for appName: String) -> URL? {
        var components = URLComponents(string: "https://itunes.apple.com/search")
        components?.queryItems = [
            URLQueryItem(name: "term", value: appName),
            URLQueryItem(name: "entity", value: "software"),
            URLQueryItem(name: "limit", value: "1"),
        ]
        return components?.url
    }

    // MARK: - Disk cache

    private var cacheDirectory: URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AppIcons", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func fileName(for appName: String) -> String {
        appName.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? appName
    }

    private func saveToDisk(appName: String, data: Data) {
        let file = cacheDirectory.appendingPathComponent(fileName(for: appName) + ".png")
        try? data.write(to: file)
    }

    private func loadFromDisk(appName: String) -> UIImage? {
        let file = cacheDirectory.appendingPathComponent(fileName(for: appName) + ".png")
        guard let data = try? Data(contentsOf: file) else { return nil }
        return UIImage(data: data)
    }

    private var attemptedSetFile: URL {
        cacheDirectory.appendingPathComponent("attempted.json")
    }

    private func saveAttemptedSet() {
        let data = try? JSONEncoder().encode(Array(attempted))
        try? data?.write(to: attemptedSetFile)
    }

    private func loadAttemptedSet() {
        guard let data = try? Data(contentsOf: attemptedSetFile),
              let list = try? JSONDecoder().decode([String].self, from: data) else { return }
        attempted = Set(list)
    }
}

// MARK: - iTunes API model

private struct ITunesSearchResult: Decodable {
    let resultCount: Int
    let results: [ITunesApp]
}

private struct ITunesApp: Decodable {
    let trackName: String?
    let bundleId: String?
    let artworkUrl100: String
    let artworkUrl512: String?
}
