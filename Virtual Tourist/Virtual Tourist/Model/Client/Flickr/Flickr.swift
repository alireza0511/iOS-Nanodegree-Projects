//
//  Flickr.swift
//  Virtual Tourist
//
//  Created by Alireza Jazzb on 12/19/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation

class Flickr : NSObject {
    // MARK: - Properties
    // shared session
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    func taskForGETMethod(_ parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        /* 2/3. Build the URL, Configure the request */        let request = NSMutableURLRequest(url: flickrURLFromParameters(parameters))
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError (_ error: String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo ))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            
        }
        /* 7. Start the request */
        task.resume()
        
        return task

        
    }
    
    func taskForGETImage(_ size: String, imageUrl: String, completionHandlerForImage: @escaping (_ imageData: Data?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        
        let url = URL(string: imageUrl)
        
        let request = URLRequest(url: url!)

        
        /* 4. Make the request */
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForImage(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            completionHandlerForImage(data, nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String: AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrConstants.Flickr.APIScheme
        components.host = FlickrConstants.Flickr.APIHost
        components.path = FlickrConstants.Flickr.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        print("url: ", components.url!)
        return components.url!
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> Flickr {
        struct Singlton {
            static var sharedInstance = Flickr()
        }
        
        return Singlton.sharedInstance
    }

}

extension Flickr {
    
    func searchByLatLng (latitude: Double, longitude: Double, totalPages: Int?, completionHandlerForPhoto: @escaping (_ result:[FlickrPhoto]?,_ error: NSError?) -> Void){
        
        // choosing a random page.
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 4000/FlickrConstants.FlickrParameterValues.PhotosPerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        
        let bbox = bboxString (latitude: latitude, longitude: longitude)
        
        let methodParameters: [String: AnyObject] = [
        FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.SearchMethod as AnyObject,FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey as AnyObject,FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat as AnyObject,FlickrConstants.FlickrParameterKeys.Extras:FlickrConstants.FlickrParameterValues.MediumURL as AnyObject,     FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback as AnyObject, FlickrConstants.FlickrParameterKeys.SafeSearch:FlickrConstants.FlickrParameterValues.UseSafeSearch as AnyObject, FlickrConstants.FlickrParameterKeys.BoundingBox: bbox as AnyObject, FlickrConstants.FlickrParameterKeys.PhotosPerPage : "\(FlickrConstants.FlickrParameterValues.PhotosPerPage)" as AnyObject,FlickrConstants.FlickrParameterKeys.Page:"\(page)" as AnyObject
        ]
        
        let _ = taskForGETMethod(methodParameters as [String:AnyObject]) { (results, error) in
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForPhoto(nil, error)
            } else {
                
                if let results = results? ["photos"] as? [String:AnyObject] {
                    
                    if let resultt = results ["photo"] as? [[String:AnyObject]]{
                        
                        let photos = FlickrPhoto.photosFromResults(resultt)
                        completionHandlerForPhoto(photos, nil)
                    }
                    
                } else {
                    completionHandlerForPhoto(nil, NSError(domain:"getphotos parsing", code : 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getphotoes"] ))
                }
            }
        }
    }
    
    private func bboxString(latitude : Double, longitude: Double) -> String {
        
        let minLat = max(latitude - FlickrConstants.Flickr.SearchBBoxHalfHeight, FlickrConstants.Flickr.SearchLatRange.0)
        let maxLat = min(latitude + FlickrConstants.Flickr.SearchBBoxHalfHeight, FlickrConstants.Flickr.SearchLatRange.1)
        let minLng = max(longitude - FlickrConstants.Flickr.SearchBBoxHalfWidth, FlickrConstants.Flickr.SearchLngRange.0)
        let maxLng = min(longitude + FlickrConstants.Flickr.SearchBBoxHalfWidth, FlickrConstants.Flickr.SearchLngRange.1)
        
        return "\(minLng),\(minLat),\(maxLng),\(maxLat)"
    }
    
   
}


