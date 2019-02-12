//
//  PlaceNewPinViewController.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/23/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import UIKit
import MapKit

class PinViewController: UIViewController, UITextFieldDelegate {
// MARK: Outlets
    @IBOutlet weak var urlLabel: UITextField!
    @IBOutlet weak var newPinMapView: MKMapView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get user's coordinated from the Model
        let myLatitude = CLLocationDegrees(StudentDataSource.sharedInstance.myLocation!.latitude)
        let myLongitude = CLLocationDegrees(StudentDataSource.sharedInstance.myLocation!.longitude)
        let myCoordinate = CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude)
        
        // Make Map annotation from Model data
        let myLocationAnnotation = MKPointAnnotation()
        myLocationAnnotation.coordinate = myCoordinate
        myLocationAnnotation.title = "\(StudentDataSource.sharedInstance.myLocation!.firstName) \(StudentDataSource.sharedInstance.myLocation!.lastName)"
        myLocationAnnotation.subtitle = "\(StudentDataSource.sharedInstance.myLocation!.mediaURL)"
        
        newPinMapView.addAnnotation(myLocationAnnotation)
        
        // Set mapView's region to match user's location
        let region = MKCoordinateRegionMakeWithDistance(myCoordinate, ParseClient.MapViewConstants.mapViewFineScale, ParseClient.MapViewConstants.mapViewFineScale)
        newPinMapView.setRegion(region, animated: true)
        
        // Set text field delegate
        urlLabel.delegate = self
    }
    
    @IBAction func submitNewPin(_ sender: UIButton) {
        guard let mediaURL = urlLabel.text, mediaURL != "" else {
            showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: "Media URL cannot be empty!", actionTitle: "Dismiss")
            return
        }
        
        let latString = String(describing: StudentDataSource.sharedInstance.myLocation!.latitude)
        let longString = String(describing: StudentDataSource.sharedInstance.myLocation!.longitude)
        
        // Check whether location exists
        if StudentDataSource.sharedInstance.locationExists {
            ParseClient.sharedInstance().putNewLocation(locationIDToReplace: StudentDataSource.sharedInstance.myLocation!.objectID, mapString: (StudentDataSource.sharedInstance.myLocation?.mapString)!, mediaURL: mediaURL, latitude: latString, longitude: longString, completionHandlerForPutNewLocation: {(success, error) in
                
                if success {
                    performUIUpdatesOnMain {
                        // Get back to Intial view - Tab bar controller
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    performUIUpdatesOnMain {
                        
                        // Alert: PUT new location failed
                        showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: (error?.userInfo[NSLocalizedDescriptionKey] as! String), actionTitle: ParseClient.ErrorStrings.dismiss)
                    }
                }
            })
        } else {
            ParseClient.sharedInstance().postNewLocation(mapString: (StudentDataSource.sharedInstance.myLocation?.mapString)!, mediaURL: mediaURL, latitude: latString, longitude: longString, completionHandlerForPostNewLocation: {(success, error) in
                
                if success {
                    // Set flag to: location does exist
                    StudentDataSource.sharedInstance.locationExists = true
                    
                    performUIUpdatesOnMain {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    performUIUpdatesOnMain {
                        
                        // Alert: POST new location failed
                        showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: (error?.userInfo[NSLocalizedDescriptionKey] as! String), actionTitle: ParseClient.ErrorStrings.dismiss)
                    }
                }
            })
        }
    }
    // MARK: Text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        urlLabel.resignFirstResponder()
        return true
    }
}
