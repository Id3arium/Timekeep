import SwiftUI
import SwiftData

struct SetupGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)

                        Text("One-Time Setup")
                            .font(.title2.weight(.bold))

                        Text("Create a single Shortcuts automation and Chronicle tracks every app you use.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)

                    // Steps
                    VStack(alignment: .leading, spacing: 16) {
                        stepRow(number: 1, text: "Open the **Shortcuts** app → **Automation** tab")
                        stepRow(number: 2, text: "Tap **+** → choose **App** as the trigger")
                        stepRow(number: 3, text: "Tap **Choose** and select every app you want to track")
                        stepRow(number: 4, text: "Make sure **Is Opened** is checked")
                        stepRow(number: 5, text: "Set to **Run Immediately** → tap **New Blank Automation**")
                        stepRow(number: 6, text: "Add a **Scripting** action: **Get Name of Current App**")
                        stepRow(number: 7, text: "Add Chronicle's **\"Log App Event\"** action below it")
                        stepRow(number: 8, text: "Set the **App Name** to the **Current App Name** variable from step 6")
                        stepRow(number: 9, text: "Tap **Done**")
                    }
                    .padding()
                    .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Tip
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                        Text("**To track new apps later**, just edit this automation and add more apps to the trigger.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.yellow.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // Delete all data
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.bottom, 32)
            }
            .alert("Delete All Data?", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all recorded app events and sessions. This cannot be undone.")
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

    private func deleteAllData() {
        do {
            try modelContext.delete(model: AppEvent.self)
            try modelContext.save()
        } catch {
            print("Failed to delete data: \(error)")
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
