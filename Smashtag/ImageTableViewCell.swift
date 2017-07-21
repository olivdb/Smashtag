//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Olivier van den Biggelaar on 19/07/2017.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {


    @IBOutlet weak var tweetImageView: UIImageView! { didSet { updateUI() } }

    var imageURL: URL? { didSet { updateUI() } }
    
    private func updateUI() {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContent = try? Data(contentsOf: url)
                if let imageData = urlContent, url == self?.imageURL {
                    DispatchQueue.main.async {
                        self?.tweetImageView?.image = UIImage(data: imageData)
                    }
                }
            }
            
        } else {
            tweetImageView?.image = nil
        }
    }

}
