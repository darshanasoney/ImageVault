import UIKit

class SavedImagesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private let viewModel = SavedImagesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Images"
        view.backgroundColor = .systemBackground
        setupCollectionView()
        bindViewModel()
    }
    private func bindViewModel() {
        
        viewModel.onImagesUpdated = { [weak self] _ in
            self?.collectionView.reloadData()
        }
        
        viewModel.onError = { [weak self] message in
            self?.showAlert(message: message)
        }
        
        viewModel.loadImages()
    }
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
    }
}

extension SavedImagesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.savedImages.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        let savedImage = viewModel.savedImages[indexPath.item]
        viewModel.loadThumbnail(for: savedImage) { image in
            cell.imageView.image = image
        }
        cell.configure(savedImage: savedImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let spacing: CGFloat = 10
        let itemsPerRow: CGFloat = 2
        let totalSpacing = (itemsPerRow - 1) * spacing
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
        return CGSize(width: width, height: width + 40)
    }
}
