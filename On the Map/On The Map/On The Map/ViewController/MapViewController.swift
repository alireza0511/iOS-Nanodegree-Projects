//
//  MapViewController.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/22/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var studentMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentMapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make annotations
        var annotations = [MKPointAnnotation]()
        for studentLocation in StudentDataSource.sharedInstance.studentLocations {
            let latitude = CLLocationDegrees(studentLocation.latitude)
            let longitude = CLLocationDegrees(studentLocation.longitude)
            
            let studentLocationCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
            
            let studentLocationAnnotation = MKPointAnnotation()
            studentLocationAnnotation.coordinate = studentLocationCoordinate
            studentLocationAnnotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            studentLocationAnnotation.subtitle = "\(studentLocation.mediaURL)"
            
            annotations.append(studentLocationAnnotation)
        }
        studentMapView.addAnnotations(annotations)
        
        var myCoordinates = CLLocationCoordinate2D(latitude: ParseClient.MapViewConstants.defaultLatitude, longitude: ParseClient.MapViewConstants.defaultLongitude)
        if let myLocation = StudentDataSource.sharedInstance.myLocation {
            myCoordinates = CLLocationCoordinate2D(latitude: myLocation.latitude, longitude: myLocation.longitude)
        }
        let region = MKCoordinateRegionMakeWithDistance(myCoordinates, ParseClient.MapViewConstants.mapViewLargeScale, ParseClient.MapViewConstants.mapViewLargeScale)
        studentMapView.setRegion(region, animated: true)
        
    }
    
    // MARK: MKMapViewDelegate functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var locationPinView = mapView.dequeueReusableAnnotationView(withIdentifier: ParseClient.MapViewConstants.pinReusableIdentifier)
        
        if locationPinView == nil {
            locationPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ParseClient.MapViewConstants.pinReusableIdentifier)
            locationPinView!.canShowCallout = true
            locationPinView!.tintColor = .blue
            locationPinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            locationPinView!.annotation = annotation
        }
        return locationPinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            var selectedStudentLocation: StudentLocation? = nil
            for location in StudentDataSource.sharedInstance.studentLocations {
                if (location.latitude == view.annotation?.coordinate.latitude) && (location.longitude == view.annotation?.coordinate.longitude) {
                    selectedStudentLocation = location
                }
            }
            
            guard let selectedLocation = selectedStudentLocation else {
                showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: "Unfind location!", actionTitle: ParseClient.ErrorStrings.dismiss)
                return
            }
            
            if let mediaURL = URL(string: selectedLocation.mediaURL), UIApplication.shared.canOpenURL(mediaURL) {
                UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
            } else {
                showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: "This student location contains no valid URL to display", actionTitle: ParseClient.ErrorStrings.dismiss)
            }
        }
    }
}
