import SwiftUI

@MainActor
final class AppIconFetcher: ObservableObject {
    static let shared = AppIconFetcher()

    /// In-memory cache of loaded images
    private var memoryCache: [String: UIImage] = [:]

    /// Apps we've attempted to fetch, with the date of the last attempt.
    /// Failed fetches are retried after 24 hours.
    private var attempted: [String: Date] = [:]

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
        migrateClearIconCache()
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

        // Trigger fetch if we haven't tried recently
        if !isRecentlyAttempted(appName) {
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
        guard !isRecentlyAttempted(appName) else { return }
        guard loadFromDisk(appName: appName) == nil else { return }
        await fetchAndCache(appName: appName)
    }

    // MARK: - Private

    private func isRecentlyAttempted(_ appName: String) -> Bool {
        guard let lastAttempt = attempted[appName] else { return false }
        return Date().timeIntervalSince(lastAttempt) < 86_400 // 24 hours
    }

    private func fetchAndCache(appName: String) async {
        attempted[appName] = Date()
        saveAttemptedSet()

        // Skip Apple apps (SF Symbols) and our own app (bundled icon)
        if Self.sfSymbols[appName] != nil || appName == "Timekeep" { return }

        guard let url = searchURL(for: appName) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let result = try? JSONDecoder().decode(ITunesSearchResult.self, from: data),
                  let firstApp = result.results.first,
                  isGoodMatch(searchName: appName, trackName: firstApp.trackName ?? ""),
                  let iconURL = URL(string: firstApp.artworkUrl512 ?? firstApp.artworkUrl100) else {
                return
            }

            let (imageData, _) = try await URLSession.shared.data(from: iconURL)
            guard let image = UIImage(data: imageData) else { return }

            saveToDisk(appName: appName, data: imageData)
            attempted.removeValue(forKey: appName)
            saveAttemptedSet()
            memoryCache[appName] = image
        } catch {
            // Silently fail — colored square fallback is fine
        }
    }

    private func isGoodMatch(searchName: String, trackName: String) -> Bool {
        let search = searchName.lowercased()
        let track = trackName.lowercased()
        // Either name contains the other (handles "Discord" vs "Discord - Chat, Talk & Hangout")
        return search.contains(track) || track.contains(search)
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

    /// One-time migration: clear all cached icons so they are re-fetched with name validation.
    private func migrateClearIconCache() {
        let key = "didMigrateIconValidation"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

        // Remove all cached icon PNGs (but keep attempted.json)
        if let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
            for file in files where file.pathExtension == "png" {
                try? FileManager.default.removeItem(at: file)
            }
        }
        // Clear in-memory state so everything is re-fetched
        memoryCache = [:]
        attempted = [:]
        saveAttemptedSet()
    }

    private var attemptedSetFile: URL {
        cacheDirectory.appendingPathComponent("attempted.json")
    }

    private func saveAttemptedSet() {
        let data = try? JSONEncoder().encode(attempted)
        try? data?.write(to: attemptedSetFile)
    }

    private func loadAttemptedSet() {
        guard let data = try? Data(contentsOf: attemptedSetFile) else { return }
        // Migrate from old format (array of strings) if needed
        if let dict = try? JSONDecoder().decode([String: Date].self, from: data) {
            attempted = dict
        } else if let list = try? JSONDecoder().decode([String].self, from: data) {
            // Old format: treat all entries as needing a retry now
            attempted = [:]
        }
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
