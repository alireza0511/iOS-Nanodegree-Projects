//
//  TopTextFieldDelegate.swift
//  ImagePickerExp
//
//  Created by Alireza Jazzb on 7/16/18.
//  Copyright © 2018 Alireza. All rights reserved.
//

import Foundation
import UIKit


class TopTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}
