import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// Photos, videos and voice notes are saved as files in the app's Documents folder.
/// The database only stores the file NAME.
enum FileStore {
    static var directory: URL {
        let url = URL.documentsDirectory.appending(path: "Relics", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func url(for filename: String) -> URL {
        directory.appending(path: filename)
    }

    /// Writes data to a new uniquely-named file and returns the file name.
    static func save(_ data: Data, ext: String) throws -> String {
        let name = UUID().uuidString + "." + ext
        try data.write(to: url(for: name))
        return name
    }

    static func delete(_ filename: String) {
        try? FileManager.default.removeItem(at: url(for: filename))
    }
}

/// Lets PhotosPicker hand us a video as a file (videos are too big to load as Data).
struct PickedMovie: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let dest = FileStore.url(for: UUID().uuidString + ".mov")
            try FileManager.default.copyItem(at: received.file, to: dest)
            return PickedMovie(url: dest)
        }
    }
}
