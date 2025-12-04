//
//  ImageCell.swift
//  ImageVault
//
//  Created by Macbook Pro on 03/12/25.
//

import UIKit

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var infoLabel : UILabel!

    func configure(savedImage: SavedImage) {
        infoLabel.text = "\(savedImage.fileSize / 1024) KB\n\(savedImage.dateString)"
    }
}
