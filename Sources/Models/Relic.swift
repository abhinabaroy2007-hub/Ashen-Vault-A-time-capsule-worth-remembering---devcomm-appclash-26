import Foundation
import SwiftData

// NOTE: this model is called "Relic" on purpose. Don't rename it to "Capsule":
// SwiftUI already has a built-in shape called Capsule.

enum MemoryKind: String, Codable {
    case photo, video, audio

    var symbol: String {
        switch self {
        case .photo: "photo"
        case .video: "video"
        case .audio: "waveform"
        }
    }
}

@Model
final class Relic {
    var uid: UUID = UUID()
    var title: String
    var note: String
    var createdAt: Date
    var unlockDate: Date
    @Relationship(deleteRule: .cascade) var items: [MemoryItem] = []

    init(title: String, note: String, unlockDate: Date) {
        self.title = title
        self.note = note
        self.createdAt = .now
        self.unlockDate = unlockDate
    }

    func isLocked(at date: Date = .now) -> Bool { unlockDate > date }
}

@Model
final class MemoryItem {
    var kindRaw: String
    var filename: String
    var createdAt: Date

    init(kind: MemoryKind, filename: String) {
        self.kindRaw = kind.rawValue
        self.filename = filename
        self.createdAt = .now
    }

    var kind: MemoryKind { MemoryKind(rawValue: kindRaw) ?? .photo }
}

/// "12d 03h 45m 10s"
func countdownString(until target: Date, from now: Date) -> String {
    let s = max(0, Int(target.timeIntervalSince(now)))
    let d = s / 86_400
    let h = (s % 86_400) / 3_600
    let m = (s % 3_600) / 60
    let sec = s % 60
    return String(format: "%dd %02dh %02dm %02ds", d, h, m, sec)
}
