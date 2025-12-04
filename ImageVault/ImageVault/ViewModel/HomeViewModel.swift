import Foundation
import UIKit

final class HomeViewModel {
    
    var onDownloadProgress: ((Double) -> Void)?
    var onDownloadCompleted: ((SavedImage) -> Void)?
    var onError: ((String) -> Void)?
    
    private let imageDownloader = ImageDownloader.shared
    private let storage = ImageStorage.shared
    
    func downloadAndSave(from urlString: String) {
        
        guard let url = URL(string: urlString),
              url.scheme?.starts(with: "http") == true else {
            onError?("Invalid or unsupported image URL.")
            return
        }
        
        imageDownloader.download(from: url) { [weak self] progress in
            print("progress--\(progress)")
            self?.onDownloadProgress?(progress)
        } completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let tempURL):
                do {
                    let data = try Data(contentsOf: tempURL)
                    guard UIImage(data: data) != nil else {
                        self.onError?("Downloaded data is not a valid image.")
                        return
                    }
                    if let saved = self.storage.saveImageData(data) {
                        self.onDownloadCompleted?(saved)
                    } else {
                        self.onError?("Failed saving image.")
                    }
                } catch {
                    self.onError?("Unable to read downloaded file.")
                }
            case .failure(let err):
                self.onError?(err.localizedDescription)
            }
        }
    }
}
