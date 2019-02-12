//
//  AppDelegate.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/20/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /*
    AWESOME
    Your project structure looks good, but I encourage you to have a look at 2 architecture below. Actually, I'm using Clean Swift for my current projects
    
    https://hackernoon.com/introducing-clean-swift-architecture-vip-770a639ad7bf
    https://medium.com/@smalam119/viper-design-pattern-for-ios-application-development-7a9703902af6
    And this is the project structure I used for this project
    https://udacity-reviews-uploads.s3.us-west-2.amazonaws.com/_attachments/138757/1529421532/Screen_Shot_2018-06-19_at_22.18.09.png
 */
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

