//
//  SavedImage.swift
//  ImageVault
//
//  Created by Macbook Pro on 04/12/25.
//

import UIKit

struct SavedImage: Codable {
    let fileName: String
    let fileSize: Int
    let dateSaved: Date

    var fileSizeString: String {
        ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: dateSaved)
    }
}
