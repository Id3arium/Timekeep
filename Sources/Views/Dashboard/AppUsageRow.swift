import SwiftUI

struct AppUsageRow: View {
    let stats: AppUsageStats
    let maxTime: TimeInterval

    var body: some View {
        HStack(spacing: 12) {
            AppIconSquare(appName: stats.appName)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(stats.appName)
                        .font(.body.weight(.medium))
                    Spacer()
                    Text(TimeFormatter.format(stats.totalTime))
                        .font(.subheadline)
                        .foregroundStyle(ColorGenerator.subtitleColor)
                }

                GeometryReader { geo in
                    let fraction = maxTime > 0 ? stats.totalTime / maxTime : 0
                    RoundedRectangle(cornerRadius: 3)
                        .fill(ColorGenerator.color(for: stats.appName).opacity(0.7))
                        .frame(width: geo.size.width * fraction)
                }
                .frame(height: 6)
            }
        }
        .padding(.vertical, 2)
    }
}
