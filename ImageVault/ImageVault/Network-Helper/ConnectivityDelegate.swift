//
//  ConnectivityDelegate.swift
//  ImageVault
//
//  Created by Macbook Pro on 04/12/25.
//


import Network

final class NetworkMonitor {

    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private(set) var isConnected: Bool = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
