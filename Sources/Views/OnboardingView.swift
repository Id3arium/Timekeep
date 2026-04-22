import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            howItWorksPage.tag(1)
            setupPage.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color(.systemBackground))
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "book.pages")
                .font(.system(size: 72))
                .foregroundStyle(.blue)

            Text("Timekeep")
                .font(.largeTitle.weight(.bold))

            Text("Your personal screen time story")
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()

            Text("Swipe to learn more →")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 40)
        }
        .padding()
    }

    private var howItWorksPage: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                featureRow(
                    icon: "arrow.triangle.branch",
                    title: "Two Shortcuts",
                    description: "Two quick Shortcuts automations detect when you open and close any tracked app and tell Timekeep."
                )

                featureRow(
                    icon: "clock",
                    title: "Session Tracking",
                    description: "Timekeep figures out when you left an app by seeing when you opened the next one."
                )

                featureRow(
                    icon: "chart.bar",
                    title: "Analytics",
                    description: "See your daily and weekly screen time with charts and breakdowns."
                )
            }
            .padding(.horizontal)

            Spacer()

            Text("Swipe to set up →")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 40)
        }
        .padding()
    }

    private var setupPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "gear.badge.checkmark")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("One-Time Setup")
                .font(.title2.weight(.bold))

            Text("Create two automations in Shortcuts — it takes about two minutes. You can always find these instructions again via the ⓘ button.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                hasCompletedOnboarding = true
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
