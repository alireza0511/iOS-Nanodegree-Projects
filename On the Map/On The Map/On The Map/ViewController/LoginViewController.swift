//
//  ViewController.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/20/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import UIKit
import MapKit

//class LoginViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
class LoginViewController: UIViewController {


    // MARK: properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
   
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset email-password fields
        emailTextField.text = nil
        passwordTextField.text = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // MARK: Actions
    @IBAction private func loginPressed(_ sender: UIButton) {
        // Start Activity indicator
        self.view.bringSubview(toFront: loginActivityIndicator)
        loginActivityIndicator.startAnimating()
        
        UdacityClient.sharedInstance().authenticateWithViewController(emailTextField.text!, passwordTextField.text!, self) { (success, error) in
            
            if success {
                ParseClient.sharedInstance().getInitialUserInfo(completionHandlerForGetIserInfo: {(success, error) in
                    if success {
                        ParseClient.sharedInstance().getAllStudentLocations(completionHandlerForGetAllStudentLocations: {(success, error) in
                            if success {
                                performUIUpdatesOnMain {
                                    self.loginActivityIndicator.stopAnimating() //Stop Activity indicator
                                    self.completeLogin() // Proceed with the next scene
                                }
                            } else {
                                performUIUpdatesOnMain {
                                    
                                    self.loginActivityIndicator.stopAnimating() //Stop Activity indicator
                                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.localizedDescription, actionTitle: ParseClient.ErrorStrings.dismiss)
                                }
                            }
                        })
                    } else {
                        performUIUpdatesOnMain {
                            
                            self.loginActivityIndicator.stopAnimating() //Stop Activity indicator
                            showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.localizedDescription, actionTitle: ParseClient.ErrorStrings.dismiss)
                        }
                    }
                })
            } else {
                performUIUpdatesOnMain {
                    
                    // Alert:
                    self.loginActivityIndicator.stopAnimating() //Stop Activity indicator
                }
            }
        }
    }
    
    private func completeLogin() {
        let navigationManagerController = storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.navigationManagerController) as! UINavigationController
        self.present(navigationManagerController, animated: true, completion: nil)
    }
    // MARK: Location Manager Delegate Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        StudentDataSource.sharedInstance.myLocation?.latitude = userLocation.coordinate.latitude
        StudentDataSource.sharedInstance.myLocation?.longitude = userLocation.coordinate.longitude
    }
    
    
}

extension LoginViewController: UITextFieldDelegate {
    // MARK: Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}

