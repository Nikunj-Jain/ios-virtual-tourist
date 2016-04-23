//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 17/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    func setPictureForCell(picture: Photo) {
        if let picturesImage = picture.photoData {
            imageView.image = UIImage(data: picturesImage)
            self.userInteractionEnabled = true
        } else {
            imageView.image = UIImage(named: "Placeholder")
            self.userInteractionEnabled = false
        }
    }
}