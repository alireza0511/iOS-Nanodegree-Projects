//
//  AddNewPinViewController.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/23/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var activityIndicater: UIActivityIndicatorView!
    @IBOutlet weak var newLocationTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newLocationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe from keyboard notifications
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Actions
    @IBAction func cancelButton (_ sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func finOnTheMap(_ sender: UIButton){
        
        self.view.bringSubview(toFront: activityIndicater)
        activityIndicater.startAnimating()
        
        if let mapString = newLocationTextField.text, mapString != "" {
            
            StudentDataSource.sharedInstance.myLocation?.mapString = mapString
            StudentDataSource.sharedInstance.myLocation?.uniqueKey = ParseClient.Constants.myUdacityID
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(mapString, completionHandler: {(placemarks, error) in
                if let placemark = placemarks?[0] {
                    StudentDataSource.sharedInstance.myLocation?.latitude = placemark.location!.coordinate.latitude
                    StudentDataSource.sharedInstance.myLocation?.longitude = placemark.location!.coordinate.longitude
                    self.activityIndicater.stopAnimating()
                    
                    let placeNewPinVC = self.storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.placeNewPinController) as! PinViewController
                    self.navigationController?.pushViewController(placeNewPinVC, animated: true)
                } else {
                    self.activityIndicater.stopAnimating()
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: "Could not geocode your location!", actionTitle: ParseClient.ErrorStrings.dismiss)
                }
            })
            
            
        } else {
            showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: "Location name cannot be empty!", actionTitle: ParseClient.ErrorStrings.dismiss)
        }
    }

    // MARK: Singleton shared instance
    class func sharedInstance() -> AddPinViewController {
        struct Singleton {
            static let sharedInstance = AddPinViewController()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newLocationTextField.resignFirstResponder()
        return true
    }
    
    // viewWillTransition - hide keyboard while turning device
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        newLocationTextField.resignFirstResponder()
    }
    
    // MARK: - Move the view when Keyboard appears
    @objc func keyboardWillShow(notification: NSNotification) {
        if newLocationTextField.isFirstResponder {
            view.frame.origin.y = getKeyboardHeight(notification: notification) * (-1)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: - Subscribe/unsubscribe to notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}
