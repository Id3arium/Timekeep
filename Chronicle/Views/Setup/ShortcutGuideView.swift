import SwiftUI

struct ShortcutGuideView: View {
    let appName: String
    let isFirstTime: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // App header
                HStack(spacing: 12) {
                    AppIconSquare(appName: appName, size: 48)
                    Text(appName)
                        .font(.title2.weight(.bold))
                }

                if isFirstTime {
                    fullGuide
                } else {
                    quickGuide
                }
            }
            .padding()
        }
        .navigationTitle("Setup \(appName)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var fullGuide: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("You need to create **2 automations** in the Shortcuts app:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Automation 1: Open
            automationCard(
                number: 1,
                title: "When \(appName) is opened",
                steps: [
                    "Open the **Shortcuts** app",
                    "Go to the **Automation** tab",
                    "Tap **+ New Automation**",
                    "Choose **App**",
                    "Select **\(appName)** and check **Is Opened**",
                    "Choose **Run Immediately**",
                    "Tap **New Blank Automation**",
                    "Add the **\"Log App Event\"** action (search for Chronicle)",
                    "Set App Name to **\(appName)**",
                    "Set Event Type to **Opened**",
                    "Tap **Done**",
                ]
            )

            // Automation 2: Close
            automationCard(
                number: 2,
                title: "When \(appName) is closed",
                steps: [
                    "Create another automation",
                    "Choose **App** → select **\(appName)** → check **Is Closed**",
                    "Choose **Run Immediately**",
                    "Add **\"Log App Event\"** action",
                    "Set App Name to **\(appName)**",
                    "Set Event Type to **Closed**",
                    "Tap **Done**",
                ]
            )

            importantNote
        }
    }

    private var quickGuide: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create 2 automations in Shortcuts:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Copy-friendly cards
            copyCard(label: "App Name", value: appName)

            VStack(alignment: .leading, spacing: 8) {
                Label("Automation 1: App → \(appName) → Is Opened → Log App Event (Opened)", systemImage: "1.circle.fill")
                    .font(.subheadline)

                Label("Automation 2: App → \(appName) → Is Closed → Log App Event (Closed)", systemImage: "2.circle.fill")
                    .font(.subheadline)
            }
            .padding()
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))

            importantNote
        }
    }

    private func automationCard(number: Int, title: String, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: "\(number).circle.fill")
                .font(.headline)

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 20, alignment: .trailing)
                    Text(.init(step))
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }

    private func copyCard(label: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body.weight(.medium))
                    .textSelection(.enabled)
            }
            Spacer()
            Button {
                UIPasteboard.general.string = value
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.body)
            }
        }
        .padding()
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }

    private var importantNote: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text("Make sure both automations are set to **Run Immediately** (not \"Ask Before Running\"), otherwise you'll get a confirmation prompt every time.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.yellow.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}
