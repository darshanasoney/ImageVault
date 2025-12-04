import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.totalCostLimit = 60 * 1024 * 1024
    }

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: NSString(string: key))
    }

    func set(_ image: UIImage, forKey key: String, cost: Int) {
        cache.setObject(image, forKey: NSString(string: key), cost: cost)
    }
}
