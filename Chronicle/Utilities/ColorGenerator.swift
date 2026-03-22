import SwiftUI

enum ColorGenerator {
    /// Deterministic color from app name using djb2 hash.
    /// Swift's hashValue is randomized per launch — this is stable.
    static func color(for appName: String) -> Color {
        let hash = djb2(appName)
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.6, brightness: 0.85)
    }

    /// Two-letter initials for an app.
    /// Known apps get custom initials; others use first two letters.
    static func initials(for appName: String) -> String {
        let custom: [String: String] = [
            "YouTube": "YT",
            "Twitter": "TW",
            "Instagram": "IG",
            "TikTok": "TK",
            "Snapchat": "SC",
            "Facebook": "FB",
            "WhatsApp": "WA",
            "Telegram": "TG",
            "LinkedIn": "LI",
            "Pinterest": "PT",
            "Messages": "MS",
            "FaceTime": "FT",
            "App Store": "AS",
            "DoorDash": "DD",
            "Uber Eats": "UE",
        ]
        if let known = custom[appName] {
            return known
        }
        let letters = appName.prefix(2).uppercased()
        return String(letters)
    }

    private static func djb2(_ string: String) -> UInt {
        var hash: UInt = 5381
        for char in string.utf8 {
            hash = ((hash &<< 5) &+ hash) &+ UInt(char)
        }
        return hash
    }
}
