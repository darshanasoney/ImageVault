import UIKit

import UIKit

final class SavedImagesViewModel {

    var onImagesUpdated: (([SavedImage]) -> Void)?
    var onError: ((String) -> Void)?

    private let storage = ImageStorage.shared

    private(set) var savedImages: [SavedImage] = [] {
        didSet { onImagesUpdated?(savedImages) }
    }

    func loadImages() {
        let images = storage.loadAllImages()

        if images.isEmpty {
            onError?("No saved images found.")
        }

        self.savedImages = images.sorted(by: { $0.dateSaved > $1.dateSaved })
    }

    func loadThumbnail(for image: SavedImage, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let uiImage = self.storage.loadImageFromDisk(image.fileName)
            DispatchQueue.main.async {
                completion(uiImage)
            }
        }
    }
}

