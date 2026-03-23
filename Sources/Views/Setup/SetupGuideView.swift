import SwiftUI

struct SetupGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)

                        Text("Track Your Screen Time")
                            .font(.title2.weight(.bold))

                        Text("For each app you want to track, you create two automations in the Shortcuts app — one for when it opens, one for when it closes.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)

                    NavigationLink {
                        AppPickerView()
                    } label: {
                        Label("Choose apps to track", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)

                    // Quick reference
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How it works")
                            .font(.headline)

                        stepRow(number: 1, text: "Open the **Shortcuts** app → **Automation** tab")
                        stepRow(number: 2, text: "Tap **+** → **App** trigger")
                        stepRow(number: 3, text: "Pick an app, check **Is Opened**, set **Run Immediately**")
                        stepRow(number: 4, text: "Tap **New Blank Automation**")
                        stepRow(number: 5, text: "Search for **\"Log App Event\"** (it's from Chronicle)")
                        stepRow(number: 6, text: "Set the **App Name** and **Event Type → Opened**")
                        stepRow(number: 7, text: "Tap **Done**, then repeat for **Is Closed**")
                    }
                    .padding()
                    .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Tip
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                        Text("**Tip:** \"Log App Event\" appears automatically in Shortcuts because Chronicle registers it as an App Intent. No setup needed — just search for it when adding an action.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.yellow.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func stepRow(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(.blue, in: Circle())

            Text(.init(text))
                .font(.subheadline)
        }
    }
}
