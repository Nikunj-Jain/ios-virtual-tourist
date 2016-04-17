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
    
    var coordinates = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        initialiseMap()
        
        FlickrSearch.sharedFlickrSearchInstance().createURLWithComponents(latitude: coordinates.latitude, longitude: coordinates.longitude)
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