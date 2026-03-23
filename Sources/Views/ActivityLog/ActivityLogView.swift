import SwiftUI
import SwiftData

struct ActivityLogView: View {
    @Query(sort: \AppEvent.timestamp, order: .reverse) private var events: [AppEvent]
    @State private var searchText = ""
    @State private var showingSetup = false

    private var sessions: [Session] {
        SessionComputer.computeSessions(from: Array(events))
    }

    private var filteredSessions: [Session] {
        if searchText.isEmpty {
            return sessions
        }
        return sessions.filter { $0.appName.localizedCaseInsensitiveContains(searchText) }
    }

    private var groupedByDay: [(date: Date, sessions: [Session])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredSessions) { session in
            calendar.startOfDay(for: session.startTime)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, sessions: $0.value.sorted { $0.startTime > $1.startTime }) }
    }

    var body: some View {
        Group {
            if events.isEmpty {
                emptyState
            } else {
                sessionList
            }
        }
        .navigationTitle("Activity log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSetup = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .sheet(isPresented: $showingSetup) {
            NavigationStack {
                SetupGuideView()
            }
        }
    }

    private var sessionList: some View {
        List {
            ForEach(groupedByDay, id: \.date) { group in
                Section(DateHelpers.sectionHeader(for: group.date)) {
                    ForEach(group.sessions) { session in
                        NavigationLink(value: session.appName) {
                            ActivityLogRow(session: session)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Search apps")
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Activity Yet", systemImage: "clock")
        } description: {
            Text("Set up Shortcuts automations to start tracking your screen time.")
        } actions: {
            Button("Setup Guide") {
                showingSetup = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
