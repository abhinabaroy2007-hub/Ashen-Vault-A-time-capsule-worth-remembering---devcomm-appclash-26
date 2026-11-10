import SwiftUI
import AVKit
import AVFoundation
import UIKit

struct RelicDetailView: View {
    let relic: Relic
    @State private var unlocked: Bool

    init(relic: Relic) {
        self.relic = relic
        // Start in the right state so an already-open relic doesn't flash "sealed".
        _unlocked = State(initialValue: relic.unlockDate <= .now)
    }

    var body: some View {
        ZStack {
            if unlocked { UnlockedView(relic: relic) } else { LockedView(relic: relic) }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sensoryFeedback(.success, trigger: unlocked)   // haptic when the seal breaks
        .task {
            // Sleep until the unlock moment, then flip the screen live.
            let wait = relic.unlockDate.timeIntervalSinceNow
            if wait > 0 {
                do { try await Task.sleep(for: .seconds(wait)) } catch { return }
            }
            withAnimation(.easeIn(duration: 1.0)) { unlocked = true }
        }
    }
}

// MARK: - Locked

struct LockedView: View {
    let relic: Relic

    var body: some View {
        ZStack {
            Backdrop(mood: .sealed)
            VStack(spacing: 24) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 72, weight: .light))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Palette.blood)
                    .frame(height: 120)
                Text("SEALED").font(.pixel(22)).foregroundStyle(Palette.blood)
                Text(relic.title).font(.pixel(12)).foregroundStyle(Palette.bone)
                    .multilineTextAlignment(.center)
                TimelineView(.periodic(from: .now, by: 1)) { ctx in
                    Text(countdownString(until: relic.unlockDate, from: ctx.date))
                        .font(.pixel(13)).foregroundStyle(Palette.ember)
                }
                Text("\(relic.items.count) memories lie within")
                    .font(.pixel(9)).foregroundStyle(Palette.bone.opacity(0.7))
            }
            .padding()
        }
    }
}

// MARK: - Unlocked

struct UnlockedView: View {
    let relic: Relic
    @State private var bannerVisible = false

    var body: some View {
        ZStack {
            Backdrop(mood: .opened)
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 64, weight: .light))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Palette.gold)
                        .frame(height: 110)
                        .opacity(bannerVisible ? 1 : 0)
                    Text("SEAL BROKEN")
                        .font(.pixel(22)).foregroundStyle(Palette.gold)
                        .opacity(bannerVisible ? 1 : 0)

                    Text(relic.title).font(.pixel(13)).foregroundStyle(Palette.bone)

                    if !relic.note.isEmpty {
                        Text(relic.note).font(.pixel(10)).foregroundStyle(Palette.bone)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .pixelPanel()
                    }

                    ForEach(relic.items.sorted { $0.createdAt < $1.createdAt }) { item in
                        MemoryItemView(item: item)
                    }
                }
                .padding()
            }
        }
        .onAppear { withAnimation(.easeIn(duration: 2)) { bannerVisible = true } }
    }
}

struct MemoryItemView: View {
    let item: MemoryItem

    var body: some View {
        switch item.kind {
        case .photo: PhotoRow(filename: item.filename)
        case .video: VideoRow(filename: item.filename)
        case .audio: AudioRow(filename: item.filename)
        }
    }
}

struct PhotoRow: View {
    let filename: String

    var body: some View {
        if let image = UIImage(contentsOfFile: FileStore.url(for: filename).path) {
            Image(uiImage: image)
                .resizable().scaledToFit()
                .overlay(Rectangle().stroke(Palette.bone, lineWidth: 3))
        }
    }
}

struct VideoRow: View {
    let filename: String
    @State private var player: AVPlayer?

    var body: some View {
        VideoPlayer(player: player)
            .frame(height: 240)
            .overlay(Rectangle().stroke(Palette.bone, lineWidth: 3))
            .onAppear { player = AVPlayer(url: FileStore.url(for: filename)) }
    }
}

struct AudioRow: View {
    let filename: String
    @State private var player: AVPlayer?
    @State private var playing = false

    var body: some View {
        Button(playing ? "■ STOP" : "▶ HEAR THE VOICE") { toggle() }
            .buttonStyle(PixelButtonStyle())
            .onReceive(NotificationCenter.default.publisher(
                for: AVPlayerItem.didPlayToEndTimeNotification)) { _ in playing = false }
    }

    private func toggle() {
        if playing {
            player?.pause()
            playing = false
        } else {
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            player = AVPlayer(url: FileStore.url(for: filename))
            player?.play()
            playing = true
        }
    }
}
