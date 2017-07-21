//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Olivier van den Biggelaar on 21/07/2017.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet {
            fetchImage()
        }
    }
    
    var cache: Cache?
    
    private func fetchImage() {
        imageView?.image = nil
        guard let url = imageURL else { return }
        
        if let cachedImageData = cache?[url] {
            imageView.image = UIImage(data: cachedImageData)
        } else {
            spinner?.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let imageData = try? Data(contentsOf: url), url == self?.imageURL {
                    DispatchQueue.main.async {
                        self?.spinner?.stopAnimating()
                        self?.imageView?.image = UIImage(data: imageData)
                        self?.cache?[url] = imageData
                    }
                }
            }
        }
    }
}
