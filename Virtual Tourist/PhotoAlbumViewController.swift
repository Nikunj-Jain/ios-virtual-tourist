//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 16/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    //View items
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let reuseIdentifier = "photoCell"
    var pin: Pin!
    var photos = [UIImage]()
    var size: CGSize!
    
    //
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchedRequest = NSFetchRequest(entityName: "Photo")
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    //Shared object context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        initialiseMap()
        
        checkAndFetch()

        //Set Collection View's delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func checkAndFetch() {
        if pin.photos?.count == 0 {
            print("Starting fetch")
            FlickrSearch.sharedFlickrSearchInstance().fetchPhotos(latitude: Double(pin.latitude), longitude: Double(pin.longitude)) { (success, errorString, imageArray) in
                if !success {
                    performUIUpdatesOnMain() {
                        createAlert(self, message: errorString!)
                    }
                } else {
                    performUIUpdatesOnMain() {
                        for image in imageArray! {
                            let photo = Photo(photo: image, context: self.sharedContext)
                            photo.belongsToPin = self.pin
                            self.photos.append(UIImage(data: image)!)
                        }
                        self.collectionView.reloadData()
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                }
            }
        } else if pin.photos?.count > 0{
            photos.removeAll()
            for photo in pin.photos!{
                photos.append(UIImage(data: photo.photoData)!)
            }
            print("Reloading")
            collectionView.reloadData()
        }
    }
    
    //Set the map properties
    func initialiseMap() {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center.latitude = Double(pin.latitude)
        mapRegion.center.longitude = Double(pin.longitude)
        mapRegion.span.latitudeDelta = 0.02
        mapRegion.span.longitudeDelta = 0.02
        mapView.region = mapRegion
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapRegion.center
        mapView.addAnnotation(annotation)
    }
}

//Data source and delegate implementation for the Collection View
extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Set data for each cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCell
        let photo = photos[indexPath.row]
        cell.imageView.image = photo
        return cell
    }
    
    //Count for number of photos
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    //Minimum horizontal size between cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    //Minimum vertical size between cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    //Cell size for each cell
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        size = collectionView.frame.size
        size.width = (size.width / 3) - 2
        size.height = size.width
        return size
    }
}