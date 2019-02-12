//
//  TabManagerViewController.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/20/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addPin(_ sender: UIBarButtonItem) {
        if StudentDataSource.sharedInstance.locationExists {
            let existAlert = UIAlertController(title: "Warning!", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .alert)
            existAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            existAlert.addAction(UIAlertAction(title: "Overwrite!", style: .destructive, handler: {control in
                let addNewPinNavigationViewController = self.storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.navigationInputController) as! UINavigationController
                self.present(addNewPinNavigationViewController, animated: true, completion: nil)
            }))
            self.present(existAlert, animated: false, completion: nil)
        } else {
            let addNewPinNavigationViewController = storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.navigationInputController) as! UINavigationController
            self.present(addNewPinNavigationViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func refreshLocation(_ sender: UIBarButtonItem) {
        ParseClient.sharedInstance().getAllStudentLocations(completionHandlerForGetAllStudentLocations: {(success, error) in
            if success {
                performUIUpdatesOnMain {
                    // Confirm the update with AlertView
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.success, message: "Database updated", actionTitle: ParseClient.ErrorStrings.dismiss)
                    
                    // Update the table ('list') view
                    ListViewController.sharedInstance().tableView.reloadData()
                    
                    // TODO: Refresh map view
                }
            } else {
                performUIUpdatesOnMain {
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.description, actionTitle: ParseClient.ErrorStrings.dismiss)
                }
            }
        })
    }
    
    @IBAction func logoutFunction(_ sender: UIBarButtonItem){
        UdacityClient.sharedInstance().deleteSessionID(completionHandlerForDeleteSessionID: {(success, error) in
            if success {
                print("ID deleted")
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                performUIUpdatesOnMain {
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.description, actionTitle: ParseClient.ErrorStrings.dismiss)
                }
            }
        })
    }
    }
