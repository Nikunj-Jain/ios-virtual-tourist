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

class TravelLocationsMapViewController: UIViewController {
    
    private let reuseID = "pin"

    //MapView outlet
    @IBOutlet weak var mapView: MKMapView!
    
    //Shared object context
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
    
    // Handle long press action to add Pin
    func handleLongPress(gestureRecogniser: UIGestureRecognizer) {
        if gestureRecogniser.state != .Began { return }
        
        let touchPoint = gestureRecogniser.locationInView(mapView)
        let mapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapCoordinate
        
        let _ = Pin(annotation: annotation, context: sharedContext)
        CoreDataStackManager.sharedInstance().saveContext()
        
        mapView.addAnnotation(annotation)
    }
    
    //Fetch the persisted Annotations
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
    
    //Save map state to disk
    func saveMap() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(mapView.region.center.latitude, forKey: MapViewKeys.LatitudeKey)
        defaults.setDouble(mapView.region.center.longitude, forKey: MapViewKeys.LongitudeKey)
        defaults.setDouble(mapView.region.span.latitudeDelta, forKey: MapViewKeys.LatitudeDeltaKey)
        defaults.setDouble(mapView.region.span.longitudeDelta, forKey: MapViewKeys.LongitudeDeltaKey)
    }
    
    //Load map state from disk
    func loadMap() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.valueForKey(MapViewKeys.LatitudeKey) != nil {
            var newRegion = MKCoordinateRegion()
            newRegion.center.latitude = defaults.doubleForKey(MapViewKeys.LatitudeKey)
            newRegion.center.longitude = defaults.doubleForKey(MapViewKeys.LongitudeKey)
            newRegion.span.latitudeDelta = defaults.doubleForKey(MapViewKeys.LatitudeDeltaKey)
            newRegion.span.longitudeDelta = defaults.doubleForKey(MapViewKeys.LongitudeDeltaKey)
            mapView.setRegion(newRegion, animated: true)
        }
        
        if let annotations = fetchAnnotations() {
            mapView.addAnnotations(annotations)
        }
    }
}

//Delegate implementation for Map View
extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    //Save map whenever region is changed.
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMap()
    }
    
    //View for annotations
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
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
    
    //Initialise and push PhotoAlbumViewController to the stack
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.returnsObjectsAsFaults = false
        let coordinates = (view.annotation?.coordinate)!
        let predicate1 = NSPredicate(format: "latitude == %Lf", coordinates.latitude)
        let predicate2 = NSPredicate(format: "longitude == %Lf", coordinates.longitude)
        fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [predicate1, predicate2])
        
        var fetchedPin = [Pin]()
        do {
            fetchedPin = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch {
            createAlert(self, message: "Cant fetch pin")
            return
        }
        
        let vc = storyboard!.instantiateViewControllerWithIdentifier("photoAlbumViewController") as! PhotoAlbumViewController
        vc.pin = fetchedPin[0]
        navigationController?.pushViewController(vc, animated: true)
    }
}