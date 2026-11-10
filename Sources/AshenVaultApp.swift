import SwiftUI
import SwiftData

@main
struct AshenVaultApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [Relic.self, MemoryItem.self])
    }
}
