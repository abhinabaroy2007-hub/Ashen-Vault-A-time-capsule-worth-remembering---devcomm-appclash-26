import AVFoundation

/// Plays all the app's sound effects.
///   SoundManager.shared.play("seal")                // one short effect
///   SoundManager.shared.startAmbient("bonfire_crackle")   // looping background
///   SoundManager.shared.stopAmbient()
/// Sound files live in the project (wav, mp3, m4a or caf), found by name without extension.
/// The speaker button on the Home screen switches effects off with the "soundOn" setting.
@MainActor
final class SoundManager {
    static let shared = SoundManager()
    private init() {}

    private var cache: [String: AVAudioPlayer] = [:]
    private var ambient: AVAudioPlayer?

    /// Effects only play when this is on (the Home screen speaker button controls it).
    private var enabled: Bool {
        UserDefaults.standard.object(forKey: "soundOn") as? Bool ?? true
    }

    // MARK: - Public

    /// A short one-time effect.
    func play(_ name: String, volume: Float = 1.0) {
        guard enabled, let player = cachedPlayer(for: name) else { return }
        activateSession()
        player.volume = volume
        player.currentTime = 0
        player.play()
    }

    /// A background sound that repeats forever (does nothing if it is already playing).
    func startAmbient(_ name: String, volume: Float = 0.3) {
        guard enabled else { return }
        if let current = ambient, current.isPlaying { return }
        guard let player = makePlayer(name) else { return }
        activateSession()
        player.numberOfLoops = -1      // -1 = loop forever
        player.volume = volume
        player.play()
        ambient = player
    }

    func stopAmbient() {
        ambient?.stop()
        ambient = nil
    }

    /// One shared audio setup for the whole app (effects, recording and playback),
    /// so none of them switches the setup under another one's feet.
    func activateSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default,
                                 options: [.defaultToSpeaker, .mixWithOthers])
        try? session.setActive(true)
    }

    // MARK: - Private

    private func cachedPlayer(for name: String) -> AVAudioPlayer? {
        if let player = cache[name] { return player }
        guard let player = makePlayer(name) else { return nil }
        player.prepareToPlay()
        cache[name] = player
        return player
    }

    private func makePlayer(_ name: String) -> AVAudioPlayer? {
        for ext in ["wav", "mp3", "m4a", "caf"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return try? AVAudioPlayer(contentsOf: url)
            }
        }
        print("Sound file not found in the project:", name)
        return nil
    }
}
