import UIKit

final class ImageStorage {
    static let shared = ImageStorage()

    private let fm = FileManager.default
    private let metaURL: URL
    private var items: [SavedImage] = []
    private let queue = DispatchQueue(label: "ImageStorage.queue", attributes: .concurrent)

    private init() {
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("SavedImages", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
        metaURL = dir.appendingPathComponent("metadata.json")
        loadMetadata()
    }

    private func loadMetadata() {
        queue.async(flags: .barrier) {
            guard let data = try? Data(contentsOf: self.metaURL) else { return }
            if let decoded = try? JSONDecoder().decode([SavedImage].self, from: data) {
                self.items = decoded.sorted { $0.dateSaved > $1.dateSaved }
            }
        }
    }

    private func saveMetadata() {
        queue.async(flags: .barrier) {
            if let data = try? JSONEncoder().encode(self.items) {
                try? data.write(to: self.metaURL, options: [.atomic])
            }
        }
    }

    func saveImageData(_ data: Data) -> SavedImage? {
        let id = UUID().uuidString
        let fileName = "\(id).jpg"
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("SavedImages", isDirectory: true)
        let url = dir.appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: [.atomic])
            let item = SavedImage(fileName: fileName, fileSize: data.count, dateSaved: Date())
            queue.async(flags: .barrier) {
                self.items.insert(item, at: 0)
                self.saveMetadata()
            }
            return item
        } catch {
            return nil
        }
    }

    func loadAllImages() -> [SavedImage] {
        var out: [SavedImage] = []
        queue.sync {
            out = self.items
        }
        return out
    }

    func loadImageFromDisk(_ fileName: String) -> UIImage? {
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("SavedImages/") .appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
