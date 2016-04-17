//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 14/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    let mapViewCenterLatitudeKey = "mapViewCenterLatitude"
    let mapViewCenterLongitudeKey = "mapViewCenterLongitude"
    let mapViewLatitudeDeltaKey = "mapViewLatitudeDelta"
    let mapViewLongitudeDeltaKey = "mapViewLongitudeDelta"

    @IBOutlet weak var mapView: MKMapView!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add long press gesture recogniser
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        loadMap()
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMap()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Function to handle long press action to add Pin
    func handleLongPress(gestureRecogniser: UIGestureRecognizer) {
        if gestureRecogniser.state != .Began { return }
        
        let touchPoint = gestureRecogniser.locationInView(mapView)
        let mapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapCoordinate
        
        let _ = Pin(annotation: annotation, context: sharedContext)
        
        mapView.addAnnotation(annotation)
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        
    }
    
    func fetchAnnotations() -> [MKPointAnnotation]?{
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            var annotationArray = [MKPointAnnotation]()
            let pinArray = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            for pin in pinArray {
                annotationArray.append(pin.getAnnotation())
            }
            return annotationArray
        } catch {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("photoAlbumViewController") as! PhotoAlbumViewController
        vc.coordinates = (view.annotation?.coordinate)!
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func saveMap() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(mapView.region.center.latitude, forKey: mapViewCenterLatitudeKey)
        defaults.setDouble(mapView.region.center.longitude, forKey: mapViewCenterLongitudeKey)
        defaults.setDouble(mapView.region.span.latitudeDelta, forKey: mapViewLatitudeDeltaKey)
        defaults.setDouble(mapView.region.span.longitudeDelta, forKey: mapViewLongitudeDeltaKey)
    }
    
    func loadMap() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.valueForKey(mapViewCenterLatitudeKey) != nil {
            var newRegion = MKCoordinateRegion()
            newRegion.center.latitude = defaults.doubleForKey(mapViewCenterLatitudeKey)
            newRegion.center.longitude = defaults.doubleForKey(mapViewCenterLongitudeKey)
            newRegion.span.latitudeDelta = defaults.doubleForKey(mapViewLatitudeDeltaKey)
            newRegion.span.longitudeDelta = defaults.doubleForKey(mapViewLongitudeDeltaKey)
            mapView.setRegion(newRegion, animated: true)
        }
        
        if let annotations = fetchAnnotations() {
            mapView.addAnnotations(annotations)
        }
    }
}