import SwiftUI

enum WidgetDesign {
    static let title = "Agent Usage"

    static let cornerRadius: CGFloat = 26
    static let contentPadding: CGFloat = 18
    static let headerSpacing: CGFloat = 14
    static let columnSpacing: CGFloat = 12
    static let columnTitleSpacing: CGFloat = 10
    static let rowSpacing: CGFloat = 12
    static let rowLabelWidth: CGFloat = 34
    static let progressBarHeight: CGFloat = 9

    static let background = Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E
    static let progressBarTrack = Color(red: 0.23, green: 0.23, blue: 0.24) // #3A3A3C
    static let primaryText = Color.white
    static let secondaryText = Color(red: 0.56, green: 0.56, blue: 0.58) // ~#8E8E93
    static let divider = Color.white.opacity(0.10)

    static let claudeAccent = Color(red: 0.83, green: 0.48, blue: 0.35) // #D37A5A
    static let codexAccent = Color(red: 0.30, green: 0.64, blue: 0.48) // #4CA37B

    static func progressColor(for remaining: Double) -> Color {
        if remaining > 50 { return Color(red: 0.30, green: 0.85, blue: 0.39) } // #4CD964
        if remaining > 20 { return Color(red: 0.96, green: 0.65, blue: 0.14) } // #F5A623
        return Color(red: 1.0, green: 0.23, blue: 0.19) // #FF3B30
    }
}

struct WidgetGlassBackground: View {
    var body: some View {
        WidgetDesign.background
    }
}

enum WidgetTypography {
    static func title(_ content: String) -> some View {
        Text(content)
            .font(.system(.subheadline, design: .rounded))
            .bold()
            .foregroundStyle(WidgetDesign.primaryText)
    }

    static func timestamp(_ content: String) -> some View {
        Text(content)
            .font(.system(.caption, design: .rounded))
            .foregroundStyle(WidgetDesign.secondaryText)
    }

    static func columnTitle(_ content: String, accent: Color) -> some View {
        Text(content)
            .font(.system(.subheadline, design: .rounded))
            .bold()
            .foregroundStyle(accent)
    }

    static func rowLabel(_ content: String) -> some View {
        Text(content)
            .font(.system(.caption, design: .rounded))
            .foregroundStyle(WidgetDesign.primaryText)
    }

    static func percentage(_ value: Int) -> some View {
        Text("\(value)%")
            .font(.system(.caption, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(WidgetDesign.primaryText)
    }

    static func resetTime(_ content: String) -> some View {
        Text(content)
            .font(.system(.caption2, design: .rounded))
            .foregroundStyle(WidgetDesign.secondaryText)
    }

    static func body(_ content: String) -> some View {
        Text(content)
            .font(.system(.caption, design: .rounded))
            .foregroundStyle(WidgetDesign.secondaryText)
    }
}

struct WidgetGlassProgressBar: View {
    let value: Double
    let tint: Color

    private var clampedFraction: CGFloat {
        CGFloat(min(max(value, 0), 100) / 100)
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let fillWidth = clampedFraction > 0 ? max(height, width * clampedFraction) : 0

            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(WidgetDesign.progressBarTrack)

                Capsule(style: .continuous)
                    .fill(tint)
                    .frame(width: fillWidth)
            }
        }
        .frame(height: WidgetDesign.progressBarHeight)
    }
}
