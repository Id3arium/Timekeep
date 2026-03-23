import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ActivityLogView()
                    .navigationDestination(for: String.self) { appName in
                        AppDetailView(appName: appName)
                    }
            }

            NavigationStack {
                DashboardView()
                    .navigationDestination(for: String.self) { appName in
                        AppDetailView(appName: appName)
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}
