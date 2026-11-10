import SwiftUI

enum Palette {
    static let ink   = Color(red: 0.05, green: 0.04, blue: 0.07)
    static let bone  = Color(red: 0.90, green: 0.85, blue: 0.73)
    static let gold  = Color(red: 0.93, green: 0.73, blue: 0.34)
    static let ember = Color(red: 0.98, green: 0.48, blue: 0.16)
    static let blood = Color(red: 0.78, green: 0.20, blue: 0.16)
}

extension Font {
    /// Uses Apple's built-in monospaced system font; no custom font file is needed.
    static func pixel(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }
}

/// A dark panel with a crisp system-drawn border.
struct PixelPanel: ViewModifier {
    var border: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(Color.white.opacity(0.07))
            .overlay(Rectangle().stroke(Palette.gold.opacity(0.45), lineWidth: border))
    }
}

extension View {
    func pixelPanel(border: CGFloat = 1) -> some View {
        modifier(PixelPanel(border: border))
    }
}

/// Button treatment uses only SwiftUI shapes, colors, and the system font.
struct PixelLabel: ViewModifier {
    var pressed = false

    func body(content: Content) -> some View {
        content
            .font(.pixel(11))
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Palette.ember.opacity(pressed ? 0.75 : 1))
            .overlay(Rectangle().stroke(Palette.bone.opacity(0.8), lineWidth: 2))
    }
}

struct PixelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(PixelLabel(pressed: configuration.isPressed))
            .offset(y: configuration.isPressed ? 2 : 0)
    }
}
