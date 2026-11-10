import SwiftUI

enum BackdropMood {
    case home, sealed, opened

    var colors: [Color] {
        switch self {
        case .home:
            [Color(red: 0.07, green: 0.09, blue: 0.17),
             Color(red: 0.17, green: 0.11, blue: 0.13), Palette.ink]
        case .sealed:
            [Color(red: 0.07, green: 0.09, blue: 0.15),
             Color(red: 0.12, green: 0.08, blue: 0.10), Palette.ink]
        case .opened:
            [Color(red: 0.20, green: 0.12, blue: 0.08),
             Color(red: 0.12, green: 0.08, blue: 0.10), Palette.ink]
        }
    }
}

/// A complete illustrated backdrop made from SwiftUI gradients and shapes.
/// It has no image, video, font, or other bundled-asset dependency.
struct Backdrop: View {
    let mood: BackdropMood

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: mood.colors, startPoint: .top, endPoint: .bottom)

                // Stars are native SwiftUI circles; their positions scale with the screen.
                ForEach(0..<18, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(index.isMultiple(of: 3) ? 0.65 : 0.3))
                        .frame(width: index.isMultiple(of: 4) ? 3 : 2,
                               height: index.isMultiple(of: 4) ? 3 : 2)
                        .position(
                            x: proxy.size.width * CGFloat((index * 37 + 13) % 97) / 100,
                            y: proxy.size.height * CGFloat((index * 23 + 8) % 48) / 100
                        )
                }

                VStack {
                    Spacer()
                    ZStack(alignment: .bottom) {
                        Ellipse()
                            .fill(Color.black.opacity(0.38))
                            .frame(width: proxy.size.width * 1.5, height: proxy.size.height * 0.25)
                            .offset(y: proxy.size.height * 0.09)
                        HStack(alignment: .bottom, spacing: 10) {
                            ruin(height: proxy.size.height * 0.18)
                            Spacer()
                            ruin(height: proxy.size.height * 0.25)
                            Spacer()
                            ruin(height: proxy.size.height * 0.15)
                        }
                        .padding(.horizontal, 18)
                        .foregroundStyle(Color.black.opacity(0.25))
                    }
                    .frame(height: proxy.size.height * 0.30)
                }

                RadialGradient(colors: [.clear, .black.opacity(0.42)], center: .center,
                               startRadius: 80, endRadius: proxy.size.height * 0.8)
            }
        }
        .ignoresSafeArea()
    }

    private func ruin(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Rectangle().frame(width: 34, height: 18)
            Rectangle().frame(width: 26, height: height)
        }
    }
}

struct PixelBonfire: View {
    var body: some View {
        ZStack {
            Circle().fill(Palette.ember.opacity(0.24)).frame(width: 120, height: 120).blur(radius: 22)
            Rectangle().fill(Palette.blood).frame(width: 20, height: 38).offset(x: -13, y: 0)
            Rectangle().fill(Palette.ember).frame(width: 20, height: 52).offset(y: -7)
            Rectangle().fill(Palette.gold).frame(width: 9, height: 30).offset(x: 3, y: 4)
            Rectangle().fill(Color(red: 0.28, green: 0.15, blue: 0.10))
                .frame(width: 58, height: 10).rotationEffect(.degrees(18)).offset(y: 26)
            Rectangle().fill(Color(red: 0.38, green: 0.20, blue: 0.11))
                .frame(width: 58, height: 10).rotationEffect(.degrees(-18)).offset(y: 26)
        }
        .accessibilityLabel("A small bonfire")
    }
}
