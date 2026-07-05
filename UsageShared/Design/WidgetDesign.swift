import SwiftUI

enum WidgetDesign {
    static let cornerRadius: CGFloat = 22
    static let contentPadding: CGFloat = 14

    static let claudeTint = Color(red: 0.85, green: 0.47, blue: 0.34)
    static let codexTint = Color(red: 0.06, green: 0.64, blue: 0.50)
}

struct WidgetGlassBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.34, green: 0.48, blue: 0.78).opacity(0.42),
                    Color(red: 0.12, green: 0.16, blue: 0.28).opacity(0.28),
                    Color(red: 0.45, green: 0.32, blue: 0.62).opacity(0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: WidgetDesign.cornerRadius, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular.tint(.white.opacity(0.18)))
        }
    }
}

enum WidgetTypography {
    static func title(_ content: String) -> some View {
        Text(content)
            .font(.headline)
            .fontDesign(.rounded)
            .bold()
    }

    static func timestamp(_ content: String) -> some View {
        Text(content)
            .font(.caption)
            .fontDesign(.rounded)
            .foregroundStyle(.secondary)
    }

    static func columnTitle(_ content: String, tint: Color) -> some View {
        Text(content)
            .font(.subheadline)
            .fontDesign(.rounded)
            .bold()
            .foregroundStyle(tint)
    }

    static func rowLabel(_ content: String) -> some View {
        Text(content)
            .font(.caption)
            .fontDesign(.rounded)
            .foregroundStyle(.secondary)
    }

    static func percentage(_ value: Int) -> some View {
        Text("\(value)%")
            .font(.caption)
            .fontDesign(.rounded)
            .monospacedDigit()
            .foregroundStyle(.primary)
    }

    static func resetTime(_ content: String) -> some View {
        Text(content)
            .font(.caption)
            .fontDesign(.rounded)
            .foregroundStyle(.tertiary)
    }

    static func body(_ content: String) -> some View {
        Text(content)
            .font(.caption)
            .fontDesign(.rounded)
            .foregroundStyle(.secondary)
    }
}

struct WidgetGlassProgressBar: View {
    let value: Double
    let tint: Color

    var body: some View {
        ProgressView(value: value, total: 100)
            .tint(tint)
            .scaleEffect(x: 1, y: 1.35, anchor: .center)
            .padding(.vertical, 2)
            .background {
                Capsule(style: .continuous)
                    .fill(.clear)
                    .glassEffect(.regular.tint(.white.opacity(0.08)))
            }
    }
}
