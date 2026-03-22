import SwiftUI

struct ActivityLogRow: View {
    let session: Session

    var body: some View {
        HStack(spacing: 12) {
            AppIconSquare(appName: session.appName)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.appName)
                    .font(.body.weight(.medium))

                if session.isActive {
                    Text("active")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.green, in: Capsule())
                } else if let duration = session.duration {
                    Text(session.isEstimated ? "~\(TimeFormatter.format(duration))" : TimeFormatter.format(duration))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(TimeFormatter.timeString(session.startTime))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
