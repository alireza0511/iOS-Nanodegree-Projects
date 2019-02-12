//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/24/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    // Mark: Authentication (POST) Methods
    
    func authenticateWithViewController(_ email: String, _ password: String, _ hostViewController: UIViewController,  completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        getSessionID(email, password) { (success, sessionID, errorString) in
            if success {
                if let sessionID = sessionID {
                    self.sessionID = sessionID
                }
            }
            completionHandlerForAuth(success,errorString)
        }
    }
    
    private func getSessionID(_ email: String?, _ password: String?, _ completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ errorString: String?) -> Void ){
        
        //        print("email: " + email! + " pass: " + password!)
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let mutableMethod: String = Methods.AuthenticationSession
        
        let jsonBody = "{\"\(UdacityClient.JSONBodyKey.RootBody)\": {\"\(UdacityClient.JSONBodyKey.UserName)\": \"\(email ?? "sample@gmail.com")\", \"\(UdacityClient.JSONBodyKey.PassWord)\": \"\(password ?? "12345")\"}}"
        
        /* 2. Make the request */
        let _ = taskForPOSTMethod(mutableMethod, parameters: [:], jsonBody: jsonBody) { (results, error) in
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForSession(false, nil, "Login Failed (Session ID).")
            } else {
                guard let accountArray = results? ["account"] as? [String:AnyObject] else {
                    print ("There is no Array")
                    return
                }
                
                if let userID = accountArray["key"] as? String {
                    print("key: " + userID)
                    self.userID = userID
                } else {
                    print("There is no key value")
                }
                
                guard let sessionArray = results?[UdacityClient.JSONResponseKeys.SessionArray] as? [String:AnyObject] else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.SessionArray) in \(results!)")
                    return
                }
                
                if let sessionID = sessionArray[UdacityClient.JSONResponseKeys.SessionID] as? String {
                    
                    completionHandlerForSession(true, sessionID, nil)
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.SessionID) in \(sessionArray)")
                    completionHandlerForSession(false, nil, "Login Failed (Session ID)." )
                }
            }
        }
    }
    
    // MARK: User Information (GET) Methods
    
    // func userInformationTabController ( completionHandlerForAuth: @escaping (_ result: []?, _ error: NSError?) -> Void) {
    
    // }
    
    // MARK: Delete a session ID (log out)
    func deleteSessionID(completionHandlerForDeleteSessionID: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        let urlForDeleteSessionID = ParseClient.sharedInstance().ParseURLFromParameters(apiHost: UdacityClient.Constants.ApiHost, apiPath: UdacityClient.Constants.ApiPath, withExtension: "/session", parameters: [:])
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookiesStorage = HTTPCookieStorage.shared
        for cookie in sharedCookiesStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        var headerParameters = [String:String]()
        if let xsrfCookie  = xsrfCookie {
            headerParameters[ParseClient.JSONHeaderField.xsrfToken] = xsrfCookie.value
        }
        
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.delete, withURL: urlForDeleteSessionID, httpHeaderFieldValue: headerParameters, httpBody: nil, completionHandlerForTask: {(data, error) in
            
            guard error == nil else {
                if (error?.description.contains("offline"))! {
                    completionHandlerForDeleteSessionID(false, NSError(domain: "deleteSessionID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Internet connection is offline"]))
                } else {
                    completionHandlerForDeleteSessionID(false, error)
                }
                return
            }
            
            let postSession = data as! [String:AnyObject]
            let sessionInfo = postSession[ParseClient.UdacityResponseKeys.session] as! [String:AnyObject]
            if let sessionID = sessionInfo[ParseClient.UdacityResponseKeys.id] as? String {
                print("DELETED: ", sessionID)
                completionHandlerForDeleteSessionID(true, nil)
            } else {
                completionHandlerForDeleteSessionID(false, NSError(domain: "deleteSessionID", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot delete session ID"]))
            }
        })
    }
}
