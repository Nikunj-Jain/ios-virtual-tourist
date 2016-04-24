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
    
    //Configure the image in cell
    func setPictureForCell(picture: Photo) {
        if picture.photoPath != nil {
            imageView.image = picture.image
            self.userInteractionEnabled = true
        } else {
            imageView.image = UIImage(named: "Placeholder")
            self.userInteractionEnabled = false
        }
    }
}