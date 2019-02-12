//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Alireza Jazzb on 12/16/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var barButton: UIButton!
    
    // 3.1
    var destination: Destination!
    
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexes : [IndexPath]!
    var deletedIndexes : [IndexPath]!
    var updatedIndexes : [IndexPath]!
    var totalPages: Int? = 0

    // 3.2
    var dataController: DataController!
    
    // 6.8
    var fetchedResultsController: NSFetchedResultsController<DestinationPhoto>!
    
    // 5.1 save  photo
    var destPhotos: [DestinationPhoto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //6.3
        updateFlowLayout(view.frame.size)
        // 3.5
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        //6.4
        updateStatusLabel("")
        
        //6.5
        guard let destination = destination else {
            return
        }
        // 6.6
        updateMapView(destination)
        // 6.7
        setupFetchedResultsControllerWith(destination)
        
        if let photos = destination.photos, photos.count == 0 {
        getFlickrPhoto(destination)
        } else {
            print("Alrady have it")
        }
    }
    // 6.9
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    fileprivate func deleteCollectionView() {
   
        let fetchRequest: NSFetchRequest<DestinationPhoto> = DestinationPhoto.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format:"destination == %@", self.destination)
        
        let objectDeleteContainer = dataController.persistentContainer.viewContext
        objectDeleteContainer.perform {
            if let result = try? objectDeleteContainer.fetch(fetchRequest){
                for photo in result {
                    objectDeleteContainer.delete(photo)
                }
            }
        }
    }
    
    @IBAction func barButtonAction(_ sender: Any) {
        let selectedItemCount = selectedIndexes.count
        if selectedItemCount > 0 {
            
            for i in 0..<selectedItemCount {
                    let photoToDelete = fetchedResultsController.object(at: selectedIndexes[i])
                    // delete
                    dataController.viewContext.delete(photoToDelete)
//                    try? dataController.viewContext.save()
            }
            try? dataController.viewContext.save()
             barButton.setTitle("New Collection", for: .normal)
            barButton.setTitleColor(.blue, for: .normal)
            selectedIndexes = []

        } else {
            // new collection
            if let photos = destination.photos, photos.count == 0 {
                barButton.isEnabled = false
                barButton.setTitleColor(.gray, for: .normal)
            } else {
                deleteCollectionView()
            }
            
            collectionView.reloadData()
            getFlickrPhoto(destination)
        }
    }
    func updateBarButton(){
        
        if selectedIndexes.count > 0 {
            barButton.setTitle("Remove Selected", for: .normal)
            barButton.setTitleColor(.red, for: .normal)
        } else {
           barButton.setTitle("New Collection", for: .normal)
            barButton.setTitleColor(.blue, for: .normal)
        }
    }
    
    private func getFlickrPhoto (_ dest: Destination){
       
        
        totalPages = totalPages! + 1
            let saveLat = Double(dest.latitude!)!
            let saveLng = Double(dest.longitude!)!
            
            activityIndicator.startAnimating()
            self.updateStatusLabel("Fetching photos ...")
            
            // last thing i make for getting data for the lat and lng
            Flickr.sharedInstance().searchByLatLng(latitude: saveLat, longitude: saveLng, totalPages: totalPages){ (success, errorString) in
                
                if (success != nil) {
                    print("success")
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.alpha = 0.0

                        self.labelStatus.text = ""
                    }
                    
                    self.savePhoto(success!, forDest: dest)
                    
                } else {
                    print ("faild")
                    print (errorString ?? "error get")
                    
                }
            }
       
    }
    
    private func savePhoto(_ photos:[FlickrPhoto], forDest: Destination){

        let j = photos.count
        if j > 0 {
        for i in 0...j-1 {
            let destinationPhoto = DestinationPhoto(context: dataController.viewContext)

                destinationPhoto.imageUrl = photos[i].url
                destinationPhoto.title = photos[i].title
                destinationPhoto.destination = forDest
            try? dataController.viewContext.save()
        }
        } else {
            performUIUpdatesOnMain {
                self.labelStatus.text = "This destination has no images"
            }
        }
    }
    
    private func updateStatusLabel (_ status: String){
        performUIUpdatesOnMain {
            self.labelStatus.text = status
        }
    }
}
// -> 3.4
extension PhotoAlbumViewController {
    private func updateMapView(_ dest: Destination) {
        // -> 3.3
        let annotation = MKPointAnnotation()
        let saveLat = Double(dest.latitude!)!
        let saveLng = Double(dest.longitude!)!
        let saveLocation = CLLocationCoordinate2DMake(saveLat, saveLng)
        mapView.centerCoordinate = saveLocation
        mapView.region = MKCoordinateRegion(center: saveLocation, span: MKCoordinateSpanMake(1, 1))
        annotation.coordinate = CLLocationCoordinate2DMake(saveLat, saveLng)
        mapView.addAnnotation(annotation) // <- 3.3
    }
    
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
} // <- 3.4

// 6.1 show photo
extension PhotoAlbumViewController {
    // 6.2
    private func updateFlowLayout (_ withSize: CGSize) {
        
        let landscape = withSize.width > withSize.height
        let space: CGFloat = landscape ? 5 : 3
        let items: CGFloat = landscape ? 2 : 3
        
        let dimension = (withSize.width - ((items + 1) * space)) / items
        
        flowLayout?.minimumInteritemSpacing = space
        flowLayout?.minimumLineSpacing = space
        flowLayout?.itemSize = CGSize (width: dimension, height: dimension)
        flowLayout?.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        
    }
    
    // 6.7
    private func setupFetchedResultsControllerWith(_ dest: Destination){
        
        let fetchRequest: NSFetchRequest<DestinationPhoto> = DestinationPhoto.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format:"destination == %@", dest)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed:\(error.localizedDescription)")
        }
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexes.append(newIndexPath!)
        case .delete:
            deletedIndexes.append(indexPath!)
        case .update:
            updatedIndexes.append(indexPath!)
            case .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
            
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = [IndexPath]()
        deletedIndexes = [IndexPath]()
        updatedIndexes = [IndexPath]()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({ () -> Void in
            
            for indexPath in self.insertedIndexes{
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexes{
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexes{
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion: nil)
        
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        cell.photoImgCell.image = nil
        cell.activityIndicatorCell.startAnimating()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        let photoViewCell = cell as! PhotoCollectionViewCell
        photoViewCell.imageUrl = photo.imageUrl!
        
        configImage(using: photoViewCell, photo: photo, collectionView: collectionView, index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.cellForItem(at: indexPath)?.alpha = 0.5
        
        selectedIndexes.append(indexPath)
        updateBarButton()
      
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        
        let photo = fetchedResultsController.object(at: forItemAt)
        if let imageUrl = photo.imageUrl {
        }
    }
    
    // MARK: - Helpers
    
    private func configImage(using cell: PhotoCollectionViewCell, photo: DestinationPhoto, collectionView: UICollectionView, index: IndexPath) {
        
        if let imageData = photo.image {
            cell.activityIndicatorCell.stopAnimating()
            cell.photoImgCell.image = UIImage(data: Data(referencing: imageData as NSData))
        } else {
            if let imageUrl = photo.imageUrl {
                cell.activityIndicatorCell.startAnimating()
                let _ = Flickr.sharedInstance().taskForGETImage("", imageUrl: imageUrl, completionHandlerForImage: { (imageData, error) in
                    if let image = UIImage (data: imageData!) {
                        performUIUpdatesOnMain {
                            if let currentCell = collectionView.cellForItem(at: index) as? PhotoCollectionViewCell {
                                currentCell.photoImgCell.image = image
                                cell.activityIndicatorCell.stopAnimating()
                                cell.activityIndicatorCell.alpha = 0.0
                            }
                            
                            photo.image = NSData(data: imageData!) as Data
                            try? self.dataController.viewContext.save()

                        }
                    }
        })
    }
}
}
}
