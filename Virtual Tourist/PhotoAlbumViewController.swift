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
    var insertedIndexPaths: [NSIndexPath]!
    
    //
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchedRequest = NSFetchRequest(entityName: "Photo")
        fetchedRequest.sortDescriptors = []
        fetchedRequest.predicate = NSPredicate(format: "belongsToPin == %@", self.pin)
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
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            createAlert(self, message: "No persistence found.")
        }

        //Set Collection View's delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchedResultsController.delegate = self
    }
    
    //Fetch new collection from Flickr
    @IBAction func newCollection(sender: UIButton) {
        fetchFromFlickr()
    }
    
    //Check if images already exist
    func checkAndFetch() {
        if pin.photos?.count == 0 {
            fetchFromFlickr()
        } else if pin.photos?.count > 0{
            photos.removeAll()
            for photo in pin.photos!{
                photos.append(UIImage(data: photo.photoData)!)
            }
            collectionView.reloadData()
        }
    }
    
    //Use FlickrSearch class to get images from Flickr's servers
    func fetchFromFlickr() {
        print("Starting fetch")
        newCollectionButton.enabled = false
        FlickrSearch.sharedFlickrSearchInstance().fetchPhotos(pin) { (success, errorString) in
            if !success {
                performUIUpdatesOnMain() {
                    createAlert(self, message: errorString!)
                }
            } else {
                performUIUpdatesOnMain() {
                    self.newCollectionButton.enabled = true
                }
            }
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
        if let fetchedObjects = fetchedResultsController.fetchedObjects{
            if fetchedObjects.count > 0 {
                let photo = fetchedObjects[indexPath.row] as! Photo
                cell.imageView.image = UIImage(data: photo.photoData)
            }
        }
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Count for number of photos
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return fetchedResultsController.sections![section].numberOfObjects
        return 30
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

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
       insertedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({ () -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
        }, completion: nil)
    }
}