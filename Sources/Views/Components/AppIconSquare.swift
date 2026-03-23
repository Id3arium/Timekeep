import SwiftUI

struct AppIconSquare: View {
    let appName: String
    var size: CGFloat = 36

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.22)
            .fill(ColorGenerator.color(for: appName))
            .frame(width: size, height: size)
            .overlay(
                Text(ColorGenerator.initials(for: appName))
                    .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            )
    }
}
