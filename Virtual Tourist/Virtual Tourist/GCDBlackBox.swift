//
//  GCDBlackBox.swift
//  Virtual Tourist
//
//  Created by Alireza Jazzb on 12/18/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
