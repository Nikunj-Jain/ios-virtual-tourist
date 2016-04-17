//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 14/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import CoreData
import MapKit

class Pin: NSManagedObject {
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(annotation: MKPointAnnotation, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = NSNumber(double: annotation.coordinate.latitude)
        longitude = NSNumber(double: annotation.coordinate.longitude)
        
    }
    
    func getAnnotation() -> MKPointAnnotation{
        let coordinate = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
}