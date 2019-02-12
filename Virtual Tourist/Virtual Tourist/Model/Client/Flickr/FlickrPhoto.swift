//
//  FlickrPhoto.swift
//  Virtual Tourist
//
//  Created by Alireza Jazzb on 12/19/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation

struct FlickrPhoto {
    // MARK: Properties
    let title: String
    let url: String
    
    init(dictionary: [String:AnyObject]) {
        title = dictionary["title"] as! String
        url = dictionary["url_m"] as! String
    }
    
    static func photosFromResults(_ results: [[String:AnyObject]]) -> [FlickrPhoto] {
        var photos = [FlickrPhoto]()
        for result in results {
            photos.append(FlickrPhoto(dictionary: result))
        }
        return photos
    }
}
