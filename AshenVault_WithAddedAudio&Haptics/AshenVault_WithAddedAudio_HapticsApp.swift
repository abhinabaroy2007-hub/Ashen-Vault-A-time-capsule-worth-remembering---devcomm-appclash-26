//
//  AshenVault_WithAddedAudio_HapticsApp.swift
//  AshenVault_WithAddedAudio&Haptics
//
//  Created by Abhinaba Roy  on 10/11/26.
//

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
