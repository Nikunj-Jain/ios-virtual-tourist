//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 17/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    @NSManaged var photoData: NSData
    @NSManaged var belongsToPin: Pin
    
    //Default init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //Custom init method with photo object.
    init (photo: NSData, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        photoData = photo
    }
}