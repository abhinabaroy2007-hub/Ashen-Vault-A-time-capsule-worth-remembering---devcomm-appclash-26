import SwiftUI
import AVFoundation

/// Full-screen background: a still image, optionally with a looping video on top.
/// If the video file is missing, you simply see the still image.
struct Backdrop: View {
    let image: String
    var video: String? = nil     // file name WITHOUT ".mp4"

    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image(image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            if let video { LoopingVideoView(name: video) }
            // Darkens top and bottom so text stays readable over any art.
            LinearGradient(colors: [.black.opacity(0.6), .black.opacity(0.1), .black.opacity(0.75)],
                           startPoint: .top, endPoint: .bottom)
        }
        .ignoresSafeArea()
    }
}

/// Wraps a UIKit view so SwiftUI can show a muted, looping video.
struct LoopingVideoView: UIViewRepresentable {
    let name: String
    var ext = "mp4"

    func makeUIView(context: Context) -> PlayerUIView { PlayerUIView(name: name, ext: ext) }
    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}

final class PlayerUIView: UIView {
    private let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?          // keeps the loop alive
    private let playerLayer = AVPlayerLayer()

    init(name: String, ext: String) {
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
            player.isMuted = true
            player.play()
        }
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
