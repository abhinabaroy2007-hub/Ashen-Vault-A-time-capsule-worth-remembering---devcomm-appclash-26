# Ashen Vault: built-in graphics version

1. Xcode: File > New > Project > iOS > App. SwiftUI, Swift, Storage: None. Minimum iOS 17.
2. Target > Build Settings > search "Default Actor Isolation" > set to nonisolated (skip if you don't see it).
3. Target > Info tab > add "Privacy - Microphone Usage Description" = "Record voice messages for your relics."
4. Delete ContentView.swift (and Item.swift if it exists) from the project.
5. Drag the 4 folders inside Sources/ (Models, Services, Theme, Views) into the project navigator.
   Tick "Copy items if needed", "Create groups", and your app target.
6. Open your existing App file (the one with @main) and replace its contents with Sources/AshenVaultApp.txt.
   (Only ONE @main is allowed in the project, so don't add it as a new file.)
7. No image assets, custom fonts, or video files are needed. The background,
   pixel-style bonfire, panels, buttons, and relic symbols are drawn with SwiftUI
   and SF Symbols. Photos/videos you add in the app are still saved as capsule media.
8. Cmd+B to build, Cmd+R to run.

The visual style uses Apple's built-in monospaced system font. The microphone
permission text is still required for voice recording.
