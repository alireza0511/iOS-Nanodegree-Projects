//
//  ParseClient.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/20/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    
    // MARK: Properties
    var sessionID: String? = nil
    var userID: String? = nil
    
    // MARK: Methods
    // Create a data task for any specified method
    func taskForMethod(_ method: MethodTypes, withURL url: URL, httpHeaderFieldValue httpHeader: [String:String], httpBody: String?, completionHandlerForTask: @escaping (_ result: AnyObject?, _ error: NSError?) throws -> Void ) -> URLSessionDataTask {
        
        // Make and configure URL request
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue
        for (field, value) in httpHeader {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        if let httpBody = httpBody {
            request.httpBody = httpBody.data(using: String.Encoding.utf8)
        }
        
        // Send a request
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            // Aux function to send Errors
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey:error]
                try! completionHandlerForTask(nil, NSError(domain: "taskForMethod", code: 1, userInfo: userInfo))
            }
            
            // Check for errors in returned data
            guard error == nil else {
                sendError("Request returned the following error: \(error!)")
                return
            }
            
            // Check returned status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    switch statusCode {
                    case 403: sendError("Forbidden: wrong username/password")
                    case 404: sendError("Not found")
                    case 405: sendError("Method not allowed")
                    default: sendError("Bad status code: \(statusCode)")
                    }
                } else {
                    sendError("Request returned a status code other than 2xx")
                }
                return
            }
            
            // Check for returned data
            guard var returnedData = data else {
                sendError("Request returned no data")
                return
            }
            
            // Remove first 5x symbols (for Udacity non-Parse responses only)
            if url.description.contains("www.udacity.com/api") {
                let range = Range(5 ..< returnedData.count)
                returnedData = returnedData.subdata(in: range)
            }
            
            // Serialize the returned data and transmit it to completion handler
            var serializedData: AnyObject! = nil
            do {
                serializedData = try JSONSerialization.jsonObject(with: returnedData, options: .allowFragments) as AnyObject
                try! completionHandlerForTask(serializedData, nil)
            } catch {
                sendError("Could not parse returned data")
                return
            }
        })
        task.resume()
        return task
    }
    
    // create a URL from parameters
    func ParseURLFromParameters(apiHost: String, apiPath: String, withExtension pathExtension: String?, parameters: [String:String]?) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = apiHost
        components.path = apiPath + (pathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: value)
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    // Make a singleton shared instance
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
