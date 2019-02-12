//
//  ParsingFunctions.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/20/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation

// Functions for extracting required data from serialized JSONs
extension ParseClient {
    

    // MARK: Retrieve User Info
    // Retrieve initial user information: first name and last name
    func getInitialUserInfo(completionHandlerForGetIserInfo: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        let urlForGetUserInfo = ParseClient.sharedInstance().ParseURLFromParameters(apiHost: UdacityClient.Constants.ApiHost, apiPath: UdacityClient.Constants.ApiPath, withExtension: "/users/\(UdacityClient.sharedInstance().userID!)", parameters: nil)
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.get, withURL: urlForGetUserInfo, httpHeaderFieldValue: [:], httpBody: nil, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForGetIserInfo(false, NSError(domain: "getInitialUserInfo", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForGetIserInfo(false, error)
                }
                return
            }
            let getUserData = data as! [String:AnyObject]
            
            // Set client shared instance's properties: user first & last names
            let userInfo = getUserData[ParseClient.UdacityUserData.user] as! [String:AnyObject]
            if let userFirstName = userInfo[ParseClient.UdacityUserData.firstName] as? String, let userLastName = userInfo[ParseClient.UdacityUserData.lastName] as? String {
                
                // Make parameteres dictionary. Set lat/long & mediaURL to defaults (will be changed at the next scene)
                let parametersForMyLocation = [ParseClient.ParseResponseKeys.firstName:userFirstName,
                                               ParseClient.ParseResponseKeys.lastName:userLastName,
                                               ParseClient.ParseResponseKeys.latitude:ParseClient.MapViewConstants.defaultLatitude,
                                               ParseClient.ParseResponseKeys.longitude:ParseClient.MapViewConstants.defaultLongitude,
                                               ParseClient.ParseResponseKeys.mediaURL:ParseClient.MapViewConstants.defaultMediaURL] as [String:AnyObject]
                
                // Init Model's 'myLocation' property
                StudentDataSource.sharedInstance.myLocation = StudentLocation(parametersForMyLocation)
                
                completionHandlerForGetIserInfo(true, nil)
            } else {
                completionHandlerForGetIserInfo(false, NSError(domain: "getInitialUserInfo", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot retrieve user info: \(ParseClient.UdacityUserData.firstName), \(ParseClient.UdacityUserData.lastName))"]))
            }
        })
    }
    
    // MARK: Get all Users locations
    func getAllStudentLocations(completionHandlerForGetAllStudentLocations: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        // Extensions for URL: limit & order
        let urlForGetAllStudentLocations = ParseClient.sharedInstance().ParseURLFromParameters(apiHost: ParseClient.Constants.ApiHost, apiPath: ParseClient.Constants.ApiPath, withExtension: nil, parameters: [ParseClient.Constants.APILimit:String(ParseClient.Constants.LimitLocations), ParseClient.Constants.APIOrder: "-\(ParseClient.ParseResponseKeys.updatedAt)"])
        
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.get, withURL: urlForGetAllStudentLocations, httpHeaderFieldValue: ParseClient.JSONHeaderCommon.jsonHeaderCommonParse, httpBody: nil, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForGetAllStudentLocations(false, NSError(domain: "getAllStudentLocations", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForGetAllStudentLocations(false, error)
                }
                return
            }
            
            let locationsData = data as! [String:AnyObject]
            guard let arrayOfLocationDicts = locationsData[ParseClient.ParseResponseKeys.results] as? [[String:AnyObject]] else {
                completionHandlerForGetAllStudentLocations(false, NSError(domain: "getAllStudentsLocations", code: 1, userInfo: [NSLocalizedDescriptionKey:"Could not parse locations data"]))
                return
            }
            
            // Clean the storage array
            StudentDataSource.sharedInstance.studentLocations = []
            
           
            for location in arrayOfLocationDicts {
                
                if let studentLocation = StudentLocation(location) {
                    StudentDataSource.sharedInstance.studentLocations.append(studentLocation)
                }
                
            }
            completionHandlerForGetAllStudentLocations(true,nil)
        })
    }
   
    // MARK: Post a new location
    func postNewLocation(mapString: String, mediaURL: String, latitude:String, longitude: String, completionHandlerForPostNewLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        let urlForPostNewLocation = ParseClient.sharedInstance().ParseURLFromParameters(apiHost: ParseClient.Constants.ApiHost, apiPath: ParseClient.Constants.ApiPath, withExtension: nil, parameters: nil)
        
        var headerParameters = ParseClient.JSONHeaderCommon.jsonHeaderCommonParse
        headerParameters[ParseClient.JSONHeaderField.contentType] = ParseClient.JSONHeaderValues.appJSON
        
        let jsonBody = "{\"uniqueKey\": \"\(ParseClient.Constants.myUdacityID)\", \"firstName\": \"\(StudentDataSource.sharedInstance.myLocation!.firstName)\", \"lastName\": \"\(StudentDataSource.sharedInstance.myLocation!.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.post, withURL: urlForPostNewLocation, httpHeaderFieldValue: headerParameters, httpBody: jsonBody, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForPostNewLocation(false, NSError(domain: "postNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForPostNewLocation(false, error)
                }
                return
            }
            
            let sessionInfo = data as! [String:AnyObject]
            if let objectID = sessionInfo[ParseClient.ParseResponseKeys.objectID] {
                StudentDataSource.sharedInstance.myLocation?.objectID = (objectID as! String)
                completionHandlerForPostNewLocation(true, nil)
            } else {
                completionHandlerForPostNewLocation(false, NSError(domain: "postNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot post a new location"]))
            }
        })
    }
    
    // MARK: Replace (put) location
    func putNewLocation(locationIDToReplace: String, mapString: String, mediaURL: String, latitude:String, longitude: String, completionHandlerForPutNewLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        let urlForPutNewLocation = ParseClient.sharedInstance().ParseURLFromParameters(apiHost: ParseClient.Constants.ApiHost, apiPath: ParseClient.Constants.ApiPath, withExtension: "/\(locationIDToReplace)", parameters: nil)
        
        var headerParameters = ParseClient.JSONHeaderCommon.jsonHeaderCommonParse
        headerParameters[ParseClient.JSONHeaderField.contentType] = ParseClient.JSONHeaderValues.appJSON
        
        let jsonBody = "{\"uniqueKey\": \"\(ParseClient.Constants.myUdacityID)\", \"firstName\": \"\(StudentDataSource.sharedInstance.myLocation!.firstName)\", \"lastName\": \"\(StudentDataSource.sharedInstance.myLocation!.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.put, withURL: urlForPutNewLocation, httpHeaderFieldValue: headerParameters, httpBody: jsonBody, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForPutNewLocation(false, NSError(domain: "putNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForPutNewLocation(false, error)
                }
                return
            }
            
            let sessionInfo = data as! [String:AnyObject]
            if let _ = sessionInfo[ParseClient.ParseResponseKeys.updatedAt] {
                completionHandlerForPutNewLocation(true, nil)
            } else {
                completionHandlerForPutNewLocation(false, NSError(domain: "putNewLocation", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot replace an existing location"]))
            }
        })
    }
}
