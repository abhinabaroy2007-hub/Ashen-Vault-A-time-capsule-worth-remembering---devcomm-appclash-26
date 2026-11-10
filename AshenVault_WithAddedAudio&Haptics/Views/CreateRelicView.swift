import SwiftUI
import SwiftData
import PhotosUI
import UIKit
import UniformTypeIdentifiers

/// A memory the user has added but not sealed yet.
struct DraftItem: Identifiable {
    let id = UUID()
    let kind: MemoryKind
    let filename: String
}

struct CreateRelicView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var note = ""
    // Default = 2 minutes from now, so you can test the whole flow quickly.
    @State private var unlockDate = Calendar.current.date(byAdding: .minute, value: 2, to: .now)!
    @State private var drafts: [DraftItem] = []
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var recorder = AudioRecorder()

    private var canSeal: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            Backdrop(image: "bg_home")

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("FORGE A RELIC")
                        .font(.pixel(16)).foregroundStyle(Palette.gold)

                    TextField("Name the relic", text: $title)
                        .font(.pixel(17)).foregroundStyle(Palette.amber)
                        .pixelPanel()

                    TextField("A message to your future self", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.pixel(17)).foregroundStyle(Palette.amber)
                        .pixelPanel()

                    DatePicker("Unseal on", selection: $unlockDate,
                               in: Date.now...,
                               displayedComponents: [.date, .hourAndMinute])
                        .font(.pixel(15)).foregroundStyle(Palette.bone)
                        .tint(Palette.ember)
                        .pixelPanel()

                    HStack(spacing: 12) {
                        PhotosPicker(selection: $pickerItems,
                                     matching: .any(of: [.images, .videos])) {
                            Text("+ PHOTO/VIDEO").modifier(PixelLabel())
                        }
                        // sounds: false -> no click, so it isn't caught on the recording
                        Button(recorder.isRecording ? "■ STOP" : "● VOICE") {
                            Task { await toggleRecording() }
                        }
                        .buttonStyle(PixelButtonStyle(sounds: false))
                    }

                    ForEach(drafts) { draft in
                        Label(draft.kind.rawValue.uppercased(), systemImage: draft.kind.symbol)
                            .font(.pixel(9)).foregroundStyle(Palette.bone)
                    }

                    // sounds: false -> this button plays its own "seal" sound instead
                    Button("SEAL THE RELIC") { seal() }
                        .buttonStyle(PixelButtonStyle(sounds: false))
                        .disabled(!canSeal)
                        .opacity(canSeal ? 1 : 0.4)
                        .padding(.top, 10)

                    Button("CANCEL") { discard() }
                        .font(.pixel(9))
                        .foregroundStyle(Palette.bone.opacity(0.7))
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: pickerItems) { _, items in
            Task { await importItems(items) }
        }
    }

    // MARK: - Actions

    /// Adds a memory to the list, with a little "rune absorbed" sound and tick.
    private func addDraft(_ kind: MemoryKind, filename: String) {
        drafts.append(DraftItem(kind: kind, filename: filename))
        SoundManager.shared.play("item_add", volume: 0.8)
        Haptics.select()
    }

    private func toggleRecording() async {
        if recorder.isRecording {
            if let name = recorder.stop() {
                Haptics.tap()
                addDraft(.audio, filename: name)
            }
        } else {
            await recorder.start()
            if recorder.isRecording { Haptics.thud() }   // buzz = "recording started"
        }
    }

    private func importItems(_ items: [PhotosPickerItem]) async {
        for item in items {
            let isVideo = item.supportedContentTypes.contains { $0.conforms(to: .movie) }
            do {
                if isVideo {
                    if let movie = try await item.loadTransferable(type: PickedMovie.self) {
                        addDraft(.video, filename: movie.url.lastPathComponent)
                    }
                } else if let data = try await item.loadTransferable(type: Data.self),
                          let jpeg = UIImage(data: data)?.jpegData(compressionQuality: 0.85) {
                    let name = try FileStore.save(jpeg, ext: "jpg")
                    addDraft(.photo, filename: name)
                }
            } catch {
                print("Import failed:", error)
            }
        }
        pickerItems = []   // reset so the same photo can be picked again
    }

    private func seal() {
        // If still recording, keep what was recorded.
        if recorder.isRecording, let name = recorder.stop() {
            drafts.append(DraftItem(kind: .audio, filename: name))
        }
        let relic = Relic(title: title, note: note, unlockDate: unlockDate)
        context.insert(relic)
        for d in drafts {
            relic.items.append(MemoryItem(kind: d.kind, filename: d.filename))
        }
        NotificationManager.schedule(title: title, at: unlockDate, id: relic.uid.uuidString)

        SoundManager.shared.play("seal")   // heavy stone thud
        Haptics.thud()
        dismiss()
    }

    private func discard() {
        _ = recorder.stop()
        for d in drafts { FileStore.delete(d.filename) }   // don't leave orphan files
        Haptics.tap()
        dismiss()
    }
}
