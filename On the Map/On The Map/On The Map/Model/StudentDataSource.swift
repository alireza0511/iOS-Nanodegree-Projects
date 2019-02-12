//
//  StudentDataSource.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/20/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import UIKit

class StudentDataSource: NSObject {
    
    // MARK: Properties
    var studentLocations = [StudentLocation]()
    
    var myLocation: StudentLocation?
    
    var locationExists = false
    
    // MARK: Singleton
    static let sharedInstance = StudentDataSource()
    
    private override init() {}
}
