//
//  PhotoViewCell.swift
//  LiveWallpapers
//
//  Created by apple on 30/03/2019.
//  Copyright © 2019 DAN. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override var bounds: CGRect {
        didSet {
            self.layoutIfNeeded()
        }
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        self.layer.cornerRadius = 18
        self.layer.borderWidth = 0.1
        self.layer.masksToBounds = true
    }
}
