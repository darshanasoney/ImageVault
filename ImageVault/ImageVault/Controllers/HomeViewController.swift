import UIKit

final class HomeViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var viewSavedButton: UIButton!
    
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var progressView : UIProgressView!

    private let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func bindViewModel() {
        
        viewModel.onDownloadProgress = { [weak self] progress in
            DispatchQueue.main.async {
                self?.progressView.setProgress(Float(progress), animated: true)
            }
        }

        viewModel.onDownloadCompleted = { [weak self] saved in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.progressView.isHidden = true
                let msg = "File with size (\(ByteCountFormatter.string(fromByteCount: Int64(saved.fileSize), countStyle: .file)) saved successfully)"
                self?.showAlert(title: "Image Vault", message: msg)
                self?.urlTextField.text = ""
            }
        }

        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.progressView.isHidden = true
                self?.showAlert(title: "Error", message: message)
            }
        }
    }

    @objc private func downloadTapped() {
        self.view.endEditing(true)
        guard let text = urlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            showAlert(title: "Invalid URL", message: "Please enter an image URL.")
            return
        }
        progressView.progress = 0
        progressView.isHidden = false
        activityIndicator.startAnimating()
        viewModel.downloadAndSave(from: text)
    }

    @objc private func viewSavedTapped() {
        self.view.endEditing(true)
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SavedImagesViewController") as? SavedImagesViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func setupUI() {
        title = "Image Vault"
        view.backgroundColor = .systemBackground
        urlTextField.borderStyle = .roundedRect
        urlTextField.autocapitalizationType = .none
        urlTextField.autocorrectionType = .no
        urlTextField.keyboardType = .URL
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)

        viewSavedButton.addTarget(self, action: #selector(viewSavedTapped), for: .touchUpInside)
        progressView.isHidden = true

    }

    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
