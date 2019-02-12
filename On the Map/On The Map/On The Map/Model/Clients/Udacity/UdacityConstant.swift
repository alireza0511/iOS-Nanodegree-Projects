//
//  UdacityConstant.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/24/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation
extension UdacityClient {
    // MARK: Constants
    struct Constants {
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let AuthorizationURL = "https://www.udacity.com/api/session"
        
       
    }
    
    struct Methods {
        // MARK: Authentication
        static let AuthenticationSession = "/session"
        
    }
    
    // MARK: Types of HTTP Methods
    enum UdacityMethodTypes: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    struct JSONResponseKeys {
        // Mark: Authorization
        static let SessionArray = "session"
        
        // MARK: Account
        static let SessionID = "id"
    }
    
    struct JSONBodyKey {
        static let RootBody = "udacity"
        static let UserName = "username"
        static let PassWord = "password"
    }
}
