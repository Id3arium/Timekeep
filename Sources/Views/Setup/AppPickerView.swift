import SwiftUI

struct AppPickerView: View {
    @AppStorage("hasSetupFirstApp") private var hasSetupFirstApp = false
    @State private var customAppName = ""
    @State private var searchText = ""

    private var filteredCategories: [(category: String, apps: [CuratedApp])] {
        if searchText.isEmpty {
            return CuratedApps.byCategory
        }
        return CuratedApps.byCategory.compactMap { group in
            let filtered = group.apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            return filtered.isEmpty ? nil : (category: group.category, apps: filtered)
        }
    }

    var body: some View {
        List {
            Section("Custom app") {
                HStack {
                    TextField("Enter app name", text: $customAppName)
                        .textInputAutocapitalization(.words)

                    if !customAppName.trimmingCharacters(in: .whitespaces).isEmpty {
                        NavigationLink(value: customAppName.trimmingCharacters(in: .whitespaces)) {
                            Text("Add")
                                .font(.subheadline.weight(.medium))
                        }
                    }
                }
            }

            ForEach(filteredCategories, id: \.category) { group in
                Section(group.category) {
                    ForEach(group.apps) { app in
                        NavigationLink(value: app.name) {
                            HStack(spacing: 12) {
                                AppIconSquare(appName: app.name, size: 32)
                                Text(app.name)
                                    .font(.body)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search apps")
        .navigationTitle("Add app")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: String.self) { appName in
            ShortcutGuideView(appName: appName, isFirstTime: !hasSetupFirstApp)
                .onDisappear {
                    hasSetupFirstApp = true
                }
        }
    }
}
