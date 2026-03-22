import SwiftUI

struct SessionRow: View {
    let session: Session
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                if let duration = session.duration {
                    Text(session.isEstimated ? "~\(TimeFormatter.format(duration))" : TimeFormatter.format(duration))
                        .font(.body.weight(.medium))
                } else if session.isActive {
                    Text("Active")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.green)
                } else {
                    Text("?")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                if let endTime = session.endTime {
                    Text(TimeFormatter.timeRange(from: session.startTime, to: endTime))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Started \(TimeFormatter.timeString(session.startTime))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
