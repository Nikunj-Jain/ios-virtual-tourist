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
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
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
                if photo.photoData != nil {
                    cell.imageView.image = UIImage(data: photo.photoData!)
                }
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        sharedContext.deleteObject(photo)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    //Count for number of photos
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (fetchedResultsController.fetchedObjects?.count)!
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
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
            
        case .Insert:
            print("Insert an item")
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            print("Delete an item")
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            updatedIndexPaths.append(indexPath!)
            break
        default:
            break
        }
    }
    
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