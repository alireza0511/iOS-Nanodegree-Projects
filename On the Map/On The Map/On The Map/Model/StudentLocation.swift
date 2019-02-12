//
//  StudentLocation.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/20/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation

struct StudentLocation {
    /*
    Tips: :star2:
    
    There are 2 ways to create a struct and parse jsonObject to struct
        
    using init() method
    extend Codable
    External Resources :books:
    
    https://medium.com/@sergueivinnitskii/easy-struct-initialization-in-swift-8ee46b8d84d5
    https://hackernoon.com/everything-about-codable-in-swift-4-97d0e18a2999
    */
    var objectID: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    
    //  returns nil if any of key properties is NOT
    init?(_ locationDictionary: [String:AnyObject]) {
        
        
        if let firstName = locationDictionary[ParseClient.ParseResponseKeys.firstName] as? String,
            let lastName = locationDictionary[ParseClient.ParseResponseKeys.lastName] as? String,
            let latitude = locationDictionary[ParseClient.ParseResponseKeys.latitude] as? Double,
            let longitude = locationDictionary[ParseClient.ParseResponseKeys.longitude] as? Double,
            let mediaURL = locationDictionary[ParseClient.ParseResponseKeys.mediaURL] as? String {
            self.firstName = firstName
            self.lastName = lastName
            self.latitude = latitude
            self.longitude = longitude
            self.mediaURL = mediaURL
        } else {
            return nil
        }
        
        //  empty string if not in parameter dictonary
        if let objectID = locationDictionary[ParseClient.ParseResponseKeys.objectID] as? String {
            self.objectID = objectID
        } else {
            self.objectID = ""
        }
        
        if let uniqueKey = locationDictionary[ParseClient.ParseResponseKeys.uniqueKey] as? String {
            self.uniqueKey = uniqueKey
        } else {
            self.uniqueKey = ""
        }
        
        if let mapString = locationDictionary[ParseClient.ParseResponseKeys.mapString] as? String {
            self.mapString = mapString
        } else {
            self.mapString = ""
        }
    }
}
