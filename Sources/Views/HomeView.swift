import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Relic.unlockDate) private var relics: [Relic]
    @State private var showingCreate = false

    var body: some View {
        NavigationStack {
            ZStack {
                Backdrop(mood: .home)

                VStack(spacing: 16) {
                    Text("ASHEN VAULT")
                        .font(.pixel(20)).foregroundStyle(Palette.gold)
                        .padding(.top, 24)

                    Spacer(minLength: 10)
                    PixelBonfire().frame(height: 150)
                    Spacer(minLength: 10)

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
        }
    }

    private func destroy(_ relic: Relic) {
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
