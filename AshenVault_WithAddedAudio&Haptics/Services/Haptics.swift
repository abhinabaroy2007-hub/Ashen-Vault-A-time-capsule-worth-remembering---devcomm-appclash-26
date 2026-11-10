import UIKit
import CoreHaptics

/// All the phone-vibration feelings in one place.
/// Use anywhere with:  Haptics.tap()   Haptics.thud()   Haptics.sealBreak()  ...
/// NOTE: the iOS Simulator cannot vibrate. Test this on a real iPhone.
@MainActor
enum Haptics {
    private static var engine: CHHapticEngine?

    /// Light tap: normal button press.
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }

    /// Heavy thump: sealing a relic, starting a recording.
    static func thud() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }

    /// Tiny tick: a memory was added.
    static func select() { UISelectionFeedbackGenerator().selectionChanged() }

    /// Happy double-buzz: opening an unlocked relic.
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }

    /// Warning buzz: sealed relic won't open, destroying a relic.
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }

    /// The big one: a rumble, four cracking hits, then a final burst.
    /// Falls back to a normal success buzz on phones that can't do custom haptics.
    static func sealBreak() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            success()
            return
        }
        do {
            let newEngine = try CHHapticEngine()
            try newEngine.start()
            Self.engine = newEngine   // keep it alive while the pattern plays

            var events: [CHHapticEvent] = []

            // 1. a low rumble that lasts almost a second
            events.append(CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.15)
                ],
                relativeTime: 0,
                duration: 0.9))

            // 2. four cracks, each one a little stronger and sharper
            let crackTimes: [TimeInterval] = [0.15, 0.40, 0.62, 0.80]
            for (i, time) in crackTimes.enumerated() {
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity,
                                               value: 0.5 + 0.12 * Float(i)),
                        CHHapticEventParameter(parameterID: .hapticSharpness,
                                               value: 0.4 + 0.15 * Float(i))
                    ],
                    relativeTime: time))
            }

            // 3. the final burst when the seal breaks
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0.95))

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try newEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            success()
        }
    }
}
