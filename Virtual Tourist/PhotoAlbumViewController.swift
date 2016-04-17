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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let reuseIdentifier = "photoCell"
    var coordinates = CLLocationCoordinate2D()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var photos = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        initialiseMap()
        
        FlickrSearch.sharedFlickrSearchInstance().fetchPhotos(latitude: coordinates.latitude, longitude: coordinates.longitude) { (success, errorString, imageArray) in
            
            if !success {
                performUIUpdatesOnMain() {
                    createAlert(self, message: errorString!)
                }
            } else {
                performUIUpdatesOnMain() {
                    for image in imageArray! {
                        let _ = Photo(photo: image, context: self.sharedContext)
                        self.photos.append(UIImage(data: image)!)
                        self.collectionView.reloadData()
                    }
                    //CoreDataStackManager.sharedInstance().saveContext()
                }
            }
        }

    
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func initialiseMap() {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center.latitude = coordinates.latitude
        mapRegion.center.longitude = coordinates.longitude
        mapRegion.span.latitudeDelta = 0.02
        mapRegion.span.longitudeDelta = 0.02
        mapView.region = mapRegion
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCell
        let photo = photos[indexPath.row]
        cell.imageView.image = photo
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
}