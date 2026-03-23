import SwiftUI

struct AppIconSquare: View {
    let appName: String
    var size: CGFloat = 36

    @ObservedObject private var iconFetcher = AppIconFetcher.shared

    var body: some View {
        if let image = iconFetcher.icon(for: appName) {
            // Real app icon from App Store
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        } else if let sfSymbol = iconFetcher.sfSymbol(for: appName) {
            // Apple app — use SF Symbol
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(ColorGenerator.color(for: appName))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: sfSymbol)
                        .font(.system(size: size * 0.45))
                        .foregroundStyle(.white)
                )
        } else {
            // Fallback — colored square with initials
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
}
