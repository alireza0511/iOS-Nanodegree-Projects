//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Alireza Jazzb on 12/22/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlet
    @IBOutlet weak var photoImgCell: UIImageView!
    @IBOutlet weak var activityIndicatorCell: UIActivityIndicatorView!
    
    static let identifier = "PhotoCollectionViewCell"
    var imageUrl: String = ""
}
