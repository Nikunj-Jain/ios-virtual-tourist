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
    
    @NSManaged var photoPath: String?
    @NSManaged var belongsToPin: Pin
    
    //Default init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //Custom init method with photo object.
    init (context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //UIImage variable that returns the UIImage corresponding to the photoPath
    var image: UIImage? {
        if photoPath != nil {
            let fileURL = getFileURL()
            return UIImage(contentsOfFile: fileURL.path!)
        }
        return nil
    }
    
    //This method is called automatically when Core Data is about to delete current object
    override func prepareForDeletion() {
        if (photoPath == nil) {
            return
        }
        let fileURL = getFileURL()
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(fileURL.path!)
            } catch let error as NSError {
                print(error.userInfo)
            }
        }
    }
    
    //Convenience method to get the fileURL
    func getFileURL() -> NSURL {
        let fileName = (photoPath! as NSString).lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let pathArray:[String] = [dirPath, fileName]
        let fileURL = NSURL.fileURLWithPathComponents(pathArray)
        return fileURL!
    }
}