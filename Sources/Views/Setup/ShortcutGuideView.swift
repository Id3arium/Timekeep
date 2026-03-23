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
                        Text("1 automation needed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Copy-friendly parameter card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Use this exact value:")
                        .font(.subheadline.weight(.medium))

                    copyRow(label: "App Name", value: appName)
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Create the automation")
                .font(.headline)

            numberedSteps([
                "Open **Shortcuts** → **Automation** tab → tap **+**",
                "Choose **App** as the trigger",
                "Select **\(appName)**, check **Is Opened**",
                "Set to **Run Immediately**, tap **New Blank Automation**",
                "Search for **\"Log App Event\"** and add it",
                "Set App Name to **\(appName)**",
                "Tap **Done**",
            ])

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
                Text("Chronicle figures out when you leave an app by seeing when you open the next one — so you only need one automation per app.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
    }

    private var quickReminder: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick reminder")
                .font(.headline)

            Text("App → \(appName) → **Is Opened** → Run Immediately → **Log App Event** → \(appName)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
            Text("The automation must be set to **Run Immediately** — otherwise you'll get a confirmation popup every time you open the app.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.yellow.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}
