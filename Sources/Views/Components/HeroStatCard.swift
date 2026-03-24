import SwiftUI

struct HeroStatCard: View {
    let label: String
    let value: String
    var percentChange: Double? = nil

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(ColorGenerator.subtitleColor)

            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded))

            if let change = percentChange {
                let isUp = change > 0
                HStack(spacing: 2) {
                    Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2)
                    Text("\(abs(Int(change)))% from last period")
                        .font(.caption)
                }
                .foregroundStyle(isUp ? .red : .green)
            }
        }
    }
}
