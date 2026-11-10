import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Relic.unlockDate) private var relics: [Relic]
    @State private var showingCreate = false
    @AppStorage("soundOn") private var soundOn = true   // speaker button; saved on the phone

    var body: some View {
        NavigationStack {
            ZStack {
                Backdrop(image: "bg_home", video: "bonfire_loop")

                VStack(spacing: 20) {
                    HStack {
                        Color.clear.frame(width: 36, height: 36)   // balances the speaker button
                        Spacer()
                        Text("ASHEN VAULT")
                            .font(.pixel(50)).foregroundStyle(Palette.gold)
                         
                        Spacer()
                        Button {
                            soundOn.toggle()
                            if soundOn {
                                SoundManager.shared.startAmbient("bonfire_crackle")
                            } else {
                                SoundManager.shared.stopAmbient()
                            }
                            Haptics.tap()
                        } label: {
                            Image(systemName: soundOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Palette.bone)
                                .frame(width: 36, height: 36)
                        }
                    }
                    Text("Leave a silent whisper for the soul you become").font(.pixel(20)).foregroundStyle(Palette.blood)
                    .padding(.horizontal)
                    .padding(.top, 24)

                    Spacer()   // the bonfire in the backdrop shows through here

                    Button("SEAL A NEW RELIC") { showingCreate = true }
                        .buttonStyle(PixelButtonStyle())

                    ScrollView {
                        LazyVStack(spacing: 14) {
                            if relics.isEmpty {
                                Text("The vault is empty.\nKindle your first memory.")
                                    .font(.pixel(9)).multilineTextAlignment(.center)
                                    .foregroundStyle(Palette.bone.opacity(0.7))
                            }
                            ForEach(relics) { relic in
                                NavigationLink(value: relic) { RelicCard(relic: relic) }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button("Destroy relic", role: .destructive) { destroy(relic) }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 280)
                }
            }
            .navigationDestination(for: Relic.self) { RelicDetailView(relic: $0) }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingCreate) { CreateRelicView() }
            .task { await NotificationManager.requestPermission() }
            // Crackling fire plays on this screen only, and pauses while you record a voice message.
            .onAppear { SoundManager.shared.startAmbient("bonfire_crackle") }
            .onDisappear { SoundManager.shared.stopAmbient() }
            .onChange(of: showingCreate) { _, showing in
                if showing {
                    SoundManager.shared.stopAmbient()
                } else {
                    SoundManager.shared.startAmbient("bonfire_crackle")
                }
            }
        }
    }

    private func destroy(_ relic: Relic) {
        Haptics.warning()
        for item in relic.items { FileStore.delete(item.filename) }
        NotificationManager.cancel(id: relic.uid.uuidString)
        context.delete(relic)
    }
}

struct RelicCard: View {
    let relic: Relic

    var body: some View {
        // Re-runs every second so the countdown is live.
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let locked = relic.isLocked(at: ctx.date)
            HStack(spacing: 12) {
                Image(systemName: locked ? "lock.fill" : "flame.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(locked ? Palette.blood : Palette.ember)
                VStack(alignment: .leading, spacing: 8) {
                    Text(relic.title)
                        .font(.pixel(12)).foregroundStyle(Palette.bone)
                    Text(locked ? countdownString(until: relic.unlockDate, from: ctx.date)
                                : "SEAL BROKEN")
                        .font(.pixel(9))
                        .foregroundStyle(locked ? Palette.ember : Palette.gold)
                }
                Spacer()
            }
            .pixelPanel()
        }
    }
}

#Preview {
    HomeView().modelContainer(for: [Relic.self, MemoryItem.self], inMemory: true)
}
