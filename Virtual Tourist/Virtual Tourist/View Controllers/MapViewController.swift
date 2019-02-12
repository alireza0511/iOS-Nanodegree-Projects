//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Alireza Jazzb on 12/12/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // MARK: Variables
    var isEditButtonOn = false
    var pinAnnotation: MKPointAnnotation? = nil
    // 2.6
    var destinations: [Destination] = []
    // 2.3
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        footerView.isHidden = true
        //-> 2.5
        let fetchRequest: NSFetchRequest<Destination> = Destination.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            destinations = result
            // -> 2.16
            for destination in destinations where destination.latitude != nil && destination.longitude != nil {
                let annotation = MKPointAnnotation()
                let saveLat = Double(destination.latitude!)!
                let saveLng = Double(destination.longitude!)!
                
                annotation.coordinate = CLLocationCoordinate2DMake(saveLat, saveLng)
                mapView.addAnnotation(annotation) // <- 2.16
            }
        } // <- 2.5
    }
    
    @IBAction func editAnnotationBtn(_ sender: UIBarButtonItem) {
        
        if isEditButtonOn {
            isEditButtonOn = false
            editButton.title = "edit"
            footerView.isHidden = true

        } else {
            isEditButtonOn = true
            editButton.title = "done"
            footerView.isHidden = false

        }
//        isEditButtonOn = isEditButtonOn ? true : false
//        editButton.title = isEditButtonOn ? "edit" : "done"
//        footerView.isHidden = isEditButtonOn
        
    }
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        let selectedLocation = sender.location(in: mapView)
        let selectedCoordinate = mapView.convert(selectedLocation, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = selectedCoordinate
            print("lat: \(selectedCoordinate.latitude), lng: \(selectedCoordinate.longitude)")
            mapView.addAnnotation(pinAnnotation!)
        } else if sender.state == .changed{
            pinAnnotation!.coordinate = selectedCoordinate
        } else if sender.state == .ended {
            //-> 2.7 add destination to coredata
            let destination = Destination(context: dataController.viewContext)
            destination.latitude = String(selectedCoordinate.latitude)
            destination.longitude = String(selectedCoordinate.longitude)
            try? dataController.viewContext.save()
            destinations.insert(destination, at: 0) // <- 2.7
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PhotoAlbumViewController {
            guard let dest = sender as? Destination else {
                print("guard")
                return
            }
            let vc = segue.destination as! PhotoAlbumViewController
            vc.destination = dest
            vc.dataController = dataController
        }
    }
}

extension MapViewController{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        
        if control == view.rightCalloutAccessoryView {
//            self.showInfo(withMessage: "No link defined")
            print("No link defined")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        
        guard let annotation = view.annotation else {
            return
        }
        
        mapView.deselectAnnotation(annotation, animated: true)
        let selectedLat = String(annotation.coordinate.latitude)
        let selectedLng = String(annotation.coordinate.longitude)
        if isEditButtonOn {
            // -> 2.9
//            let selectedLat = String(annotation.coordinate.latitude)
//            let selectedLng = String(annotation.coordinate.longitude)
            // <- 2.9
            // -> 2.11
            if let dist = getDestination(lat: selectedLat, lng: selectedLng){
                dataController.viewContext.delete(dist)
                do {
                    try self.dataController.viewContext.save()
                    mapView.removeAnnotation(annotation)
                } catch {
                    print("alert")
                }
                return
            } // <- 2.11
            // delete 2.12
            // -> 2.8
//            let destinationToDelete = destinations(at: IndexPath)
//            dataController.viewContext.delete(destinationToDelete)
//            try? dataController.viewContext.save()
//            destinations.remove(at: IndexPath.row) // <- 2.8
            
         //   mapView.removeAnnotation(annotation)
            return
        }
        
        let dist = getDestination(lat: selectedLat, lng: selectedLng)
        performSegue(withIdentifier: "travelAlbum", sender: dist)
    }
    // -> 2.10
    private func getDestination(lat: String, lng: String) -> Destination? {
        
        let fetchRequest: NSFetchRequest<Destination> = Destination.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "latitude == %@ And longitude == %@", lat, lng)

        if let results = try? dataController.viewContext.fetch(fetchRequest){
            
            if results.count <= 0 {
                return nil
            }

            let dest = results[0]
            return dest
        }
        return nil
    } // <- 2.10
}
