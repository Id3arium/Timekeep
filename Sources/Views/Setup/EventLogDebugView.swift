import SwiftUI
import SwiftData

struct EventLogDebugView: View {
    @Query(sort: \AppEvent.timestamp, order: .reverse) private var events: [AppEvent]

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm:ss a"
        return f
    }()

    var body: some View {
        List {
            Section("Raw Events (\(events.count))") {
                ForEach(events, id: \.id) { event in
                    HStack(spacing: 8) {
                        // Event type badge
                        Text(event.eventType)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                event.eventType == "opened" ? Color.green : Color.red,
                                in: Capsule()
                            )

                        VStack(alignment: .leading, spacing: 1) {
                            Text(event.appName)
                                .font(.subheadline.weight(.medium))
                            Text(timeFormatter.string(from: event.timestamp))
                                .font(.caption2)
                                .foregroundStyle(ColorGenerator.subtitleColor)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Raw Events")
        .navigationBarTitleDisplayMode(.inline)
    }
}
