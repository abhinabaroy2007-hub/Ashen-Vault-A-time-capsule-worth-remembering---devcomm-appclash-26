import AVFoundation
import Observation

@MainActor
@Observable
final class AudioRecorder {
    private(set) var isRecording = false
    private var recorder: AVAudioRecorder?
    private var filename: String?

    func start() async {
        guard await AVAudioApplication.requestRecordPermission() else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            let name = UUID().uuidString + ".m4a"
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            recorder = try AVAudioRecorder(url: FileStore.url(for: name), settings: settings)
            recorder?.record()
            filename = name
            isRecording = true
        } catch {
            print("Recording failed:", error)
        }
    }

    /// Stops recording and returns the saved file name.
    func stop() -> String? {
        recorder?.stop()
        recorder = nil
        isRecording = false
        let name = filename
        filename = nil
        return name
    }
}
