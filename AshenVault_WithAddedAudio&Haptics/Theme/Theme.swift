import SwiftUI

enum Palette {
    static let ink   = Color(red: 0.05, green: 0.04, blue: 0.07)
    static let bone  = Color(red: 0.85, green: 0.80, blue: 0.68)
    static let gold  = Color(red: 0.86, green: 0.70, blue: 0.30)
    static let ember = Color(red: 0.95, green: 0.50, blue: 0.15)
    static let blood = Color(red: 0.70, green: 0.12, blue: 0.12)
    static let amber = Color(red: 0.91, green: 0.60, blue: 0.23)
}

/// If you swap in your own panel.png / button.png, change these two numbers.
/// They are the thickness of the frame drawn in your image, in points.
enum PixelMetrics {
    static let panelBorder: CGFloat = 16
    static let buttonBorder: CGFloat = 10
}

extension Font {
    /// Press Start 2P if you installed it; otherwise SwiftUI quietly uses the system font.
    static func pixel(_ size: CGFloat) -> Font {
        .custom("PressStart2P", size: size)
    }
}

extension Image {
    /// Use on every pixel-art image so it stays crisp instead of blurry.
    func pixelArt() -> some View {
        self.interpolation(.none).resizable().scaledToFit()
    }
}

/// Wraps any content in the "panel" image (a 9-slice frame).
struct PixelPanel: ViewModifier {
    var border: CGFloat = PixelMetrics.panelBorder

    func body(content: Content) -> some View {
        content
            .padding(border)
            .background(
                Image("panel")
                    .interpolation(.none)
                    .resizable(capInsets: EdgeInsets(top: border, leading: border,
                                                     bottom: border, trailing: border),
                               resizingMode: .stretch)
            )
    }
}

extension View {
    func pixelPanel(border: CGFloat = PixelMetrics.panelBorder) -> some View {
        modifier(PixelPanel(border: border))
    }
}

/// The look of a button, using the "button" image. Reused by PhotosPicker's label.
struct PixelLabel: ViewModifier {
    var pressed = false
    var border: CGFloat = PixelMetrics.buttonBorder

    func body(content: Content) -> some View {
        content
            .font(.pixel(11))
            .foregroundStyle(Palette.bone)
            .padding(.horizontal, 26)
            .padding(.vertical, 16)
            .background(
                Image("button")
                    .interpolation(.none)
                    .resizable(capInsets: EdgeInsets(top: border, leading: border,
                                                     bottom: border, trailing: border),
                               resizingMode: .stretch)
                    .brightness(pressed ? -0.2 : 0)   // pressed look without a second image
            )
    }
}

/// Every button using this style clicks and buzzes when pressed.
/// Use PixelButtonStyle(sounds: false) where a button plays its own sound instead.
struct PixelButtonStyle: ButtonStyle {
    var sounds = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(PixelLabel(pressed: configuration.isPressed))
            .offset(y: configuration.isPressed ? 2 : 0)
            .onChange(of: configuration.isPressed) { _, pressed in
                guard pressed, sounds else { return }
                SoundManager.shared.play("button_click", volume: 0.7)
                Haptics.tap()
            }
    }
}
