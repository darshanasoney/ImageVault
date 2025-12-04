//
//  ImageDownloader.swift
//  ImageVault
//
//  Created by Macbook Pro on 04/12/25.
//


import Foundation

enum DownloadError: Error {
    case invalidResponse
    case invalidImage
    case networkError
    case badStatusCode(Int)
    case timeout
}

final class ImageDownloader: NSObject {

    static let shared = ImageDownloader()

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    private var progressHandlers: [Int: (Double) -> Void] = [:]
    private var completionHandlers: [Int: (Result<URL, DownloadError>) -> Void] = [:]

    private override init() {}

    // MARK: - Download API
    func download(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, DownloadError>) -> Void
    ) {

        if !NetworkMonitor.shared.isConnected {
            completion(.failure(.networkError))
        }
        
        var request = URLRequest(url: url)
        request.setValue("image/*", forHTTPHeaderField: "Accept")

        let task = session.downloadTask(with: request)
        let id = task.taskIdentifier

        progressHandlers[id] = progress
        completionHandlers[id] = completion

        task.resume()
    }
}

extension ImageDownloader: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        let id = downloadTask.taskIdentifier

        let progress = totalBytesExpectedToWrite > 0
            ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            : 0

        DispatchQueue.main.async {
            self.progressHandlers[id]?(progress)
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {

        let id = downloadTask.taskIdentifier

        guard let response = downloadTask.response as? HTTPURLResponse else {
            finish(id, with: .failure(.invalidResponse))
            return
        }

        guard (200...299).contains(response.statusCode) else {
            finish(id, with: .failure(.badStatusCode(response.statusCode)))
            return
        }

        guard let mime = response.mimeType, mime.hasPrefix("image") else {
            finish(id, with: .failure(.invalidImage))
            return
        }

        // Save to cache
        let fm = FileManager.default
        let cache = fm.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dest = cache.appendingPathComponent(UUID().uuidString + ".jpg")

        do {
            try fm.moveItem(at: location, to: dest)
            finish(id, with: .success(dest))
        } catch {
            finish(id, with: .failure(.networkError))
        }
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {

        guard let error = error else { return }

        let id = task.taskIdentifier
        let nsError = error as NSError

        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut {
            finish(id, with: .failure(.timeout))
        } else {
            finish(id, with: .failure(.networkError))
        }
    }

    private func finish(_ id: Int, with result: Result<URL, DownloadError>) {
        DispatchQueue.main.async {
            self.completionHandlers[id]?(result)
        }
    }
}
