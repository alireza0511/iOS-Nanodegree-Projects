//
//  MemeDetailViewController.swift
//  ImagePickerExp
//
//  Created by Alireza Jazzb on 7/27/18.
//  Copyright © 2018 Alireza. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    var meme: Meme!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.imageView!.image = self.meme.memeImage
    }
}
