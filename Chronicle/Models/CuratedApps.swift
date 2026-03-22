import Foundation

struct CuratedApp: Identifiable {
    let id = UUID()
    let name: String
    let category: String
}

enum CuratedApps {
    static let all: [CuratedApp] = [
        // Social
        CuratedApp(name: "Twitter", category: "Social"),
        CuratedApp(name: "Instagram", category: "Social"),
        CuratedApp(name: "TikTok", category: "Social"),
        CuratedApp(name: "Snapchat", category: "Social"),
        CuratedApp(name: "Reddit", category: "Social"),
        CuratedApp(name: "Facebook", category: "Social"),
        CuratedApp(name: "Threads", category: "Social"),
        CuratedApp(name: "Bluesky", category: "Social"),
        CuratedApp(name: "LinkedIn", category: "Social"),
        CuratedApp(name: "Pinterest", category: "Social"),

        // Entertainment
        CuratedApp(name: "YouTube", category: "Entertainment"),
        CuratedApp(name: "Netflix", category: "Entertainment"),
        CuratedApp(name: "Twitch", category: "Entertainment"),
        CuratedApp(name: "Spotify", category: "Entertainment"),
        CuratedApp(name: "Apple Music", category: "Entertainment"),
        CuratedApp(name: "Podcasts", category: "Entertainment"),
        CuratedApp(name: "Disney+", category: "Entertainment"),

        // Messaging
        CuratedApp(name: "Messages", category: "Messaging"),
        CuratedApp(name: "WhatsApp", category: "Messaging"),
        CuratedApp(name: "Telegram", category: "Messaging"),
        CuratedApp(name: "Discord", category: "Messaging"),
        CuratedApp(name: "Slack", category: "Messaging"),
        CuratedApp(name: "Signal", category: "Messaging"),

        // Browsing
        CuratedApp(name: "Safari", category: "Browsing"),
        CuratedApp(name: "Chrome", category: "Browsing"),
        CuratedApp(name: "Firefox", category: "Browsing"),

        // Productivity
        CuratedApp(name: "Mail", category: "Productivity"),
        CuratedApp(name: "Notes", category: "Productivity"),
        CuratedApp(name: "Calendar", category: "Productivity"),
        CuratedApp(name: "Reminders", category: "Productivity"),
        CuratedApp(name: "Files", category: "Productivity"),
        CuratedApp(name: "Notion", category: "Productivity"),

        // Shopping & Food
        CuratedApp(name: "Amazon", category: "Shopping"),
        CuratedApp(name: "DoorDash", category: "Shopping"),
        CuratedApp(name: "Uber Eats", category: "Shopping"),

        // News
        CuratedApp(name: "Apple News", category: "News"),
        CuratedApp(name: "NYT", category: "News"),

        // Other
        CuratedApp(name: "Photos", category: "Other"),
        CuratedApp(name: "Camera", category: "Other"),
        CuratedApp(name: "Maps", category: "Other"),
        CuratedApp(name: "Weather", category: "Other"),
    ]

    static var byCategory: [(category: String, apps: [CuratedApp])] {
        let grouped = Dictionary(grouping: all) { $0.category }
        let order = ["Social", "Entertainment", "Messaging", "Browsing", "Productivity", "Shopping", "News", "Other"]
        return order.compactMap { category in
            guard let apps = grouped[category] else { return nil }
            return (category: category, apps: apps)
        }
    }
}
