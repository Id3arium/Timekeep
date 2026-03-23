import SwiftUI

struct ShortcutGuideView: View {
    let appName: String
    let isFirstTime: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var copiedField: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // App header
                HStack(spacing: 12) {
                    AppIconSquare(appName: appName, size: 48)
                    VStack(alignment: .leading) {
                        Text(appName)
                            .font(.title2.weight(.bold))
                        Text("2 automations needed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Copy-friendly parameter card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Use these exact values:")
                        .font(.subheadline.weight(.medium))

                    copyRow(label: "App Name", value: appName)
                    copyRow(label: "Event Type (1st)", value: "Opened")
                    copyRow(label: "Event Type (2nd)", value: "Closed")
                }
                .padding()
                .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 16))

                if isFirstTime {
                    detailedSteps
                } else {
                    quickReminder
                }

                importantNote
            }
            .padding()
        }
        .navigationTitle("Setup \(appName)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func copyRow(label: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
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
                withAnimation {
                    copiedField = label
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        if copiedField == label { copiedField = nil }
                    }
                }
            } label: {
                if copiedField == label {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "doc.on.doc")
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var detailedSteps: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Automation 1: Opened")
                .font(.headline)

            numberedSteps([
                "Open **Shortcuts** → **Automation** tab → tap **+**",
                "Choose **App** as the trigger",
                "Select **\(appName)**, check **Is Opened**",
                "Set to **Run Immediately**, tap **New Blank Automation**",
                "Search for **\"Log App Event\"** and add it",
                "Set App Name to **\(appName)** and Event Type to **Opened**",
                "Tap **Done**",
            ])

            Divider()

            Text("Automation 2: Closed")
                .font(.headline)

            Text("Same steps, but select **Is Closed** as the trigger and set Event Type to **Closed**.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var quickReminder: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick reminder")
                .font(.headline)

            Text("Create 2 automations in Shortcuts:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: 8) {
                Text("1.")
                    .font(.subheadline.weight(.medium))
                Text("App → \(appName) → **Is Opened** → Log App Event → **Opened**")
                    .font(.subheadline)
            }

            HStack(alignment: .top, spacing: 8) {
                Text("2.")
                    .font(.subheadline.weight(.medium))
                Text("App → \(appName) → **Is Closed** → Log App Event → **Closed**")
                    .font(.subheadline)
            }
        }
    }

    private func numberedSteps(_ steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 20, alignment: .trailing)
                    Text(.init(step))
                        .font(.subheadline)
                }
            }
        }
    }

    private var importantNote: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text("Both automations must be set to **Run Immediately** — otherwise you'll get a popup every time you switch apps.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.yellow.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}
