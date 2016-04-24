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
    var size: CGSize!
    
    //Variables to keep track of changes in Core Data
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    //NSFetchedResultsController to get fetched results from CoreData
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "belongsToPin == %@", self.pin)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    //Shared object context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    //View lifecycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            createAlert(self, message: "No persistence found.")
        }
        
        //Set Collection View's delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchedResultsController.delegate = self
        
        initialiseMap()
        checkAndFetch()
    }
    
    //Delete old collection and fetch new collection from Flickr
    @IBAction func newCollection(sender: UIButton) {
        if let photos = fetchedResultsController.fetchedObjects {
            if photos.count > 0 {
                var i = photos.count - 1
                while i >= 0 {
                    let photo = photos[i] as! Photo
                    sharedContext.deleteObject(photo)
                    i--
                }
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
        fetchFromFlickr()
    }
    
    //Check if images already exist
    func checkAndFetch() {
        if pin.photos?.count == 0 {
            fetchFromFlickr()
        } else if pin.photos?.count > 0{
            collectionView.reloadData()
        }
    }
    
    //Use FlickrSearch class to get images from Flickr's servers
    func fetchFromFlickr() {
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
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        cell.setPictureForCell(photo)
        return cell
    }
    
    //Implementation for deleting tapped photo.
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        sharedContext.deleteObject(photo)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    //Return number of sections
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    //Count for number of photos
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return (fetchedResultsController.fetchedObjects?.count)!
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
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
        if let size = size {
            return size
        } else {
            size = collectionView.frame.size
            size.width = (size.width / 3) - 2
            size.height = size.width
            return size;
        }
    }
}

//Delegate implementation for NSFetchedResultsController
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    //Content will be changed
    func controllerWillChangeContent(controller: NSFetchedResultsController) {

        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
    }
    
    //Object changed at indexPath
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
            
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
            break
        default:
            break
        }
    }
    
    //Content did change
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
        }, completion: nil)
    }
}