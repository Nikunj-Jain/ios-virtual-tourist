//
//  FlickrSearch.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 16/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import UIKit
import CoreData

public class FlickrSearch {
    
    //Shared class instance.
    private static var sharedInstance = FlickrSearch()
    class func sharedFlickrSearchInstance() -> FlickrSearch {
        return sharedInstance
    }
    
    //Shared object context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    //Fetch a photo array from Flickr search results
    func fetchPhotos(pin: Pin, fetchPhotosCompletionHandler: (success: Bool, errorString: String?) -> Void) {
        let queryURL = createURLWithComponents(latitude: Double(pin.latitude), longitude: Double(pin.longitude))
        let request = NSURLRequest(URL: queryURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error)  in
            
            if error != nil {
                fetchPhotosCompletionHandler(success: false, errorString: Errors.internetConnection)
                return
            }
            
            //Parse the serialised JSON data
            let parsedData: AnyObject!
            do {
                parsedData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                fetchPhotosCompletionHandler(success: false, errorString: Errors.corruptData)
                return
            }
            
            //Extract dictionary of photos
            guard let photosDictionary = parsedData[Flickr.Values.photos] as? [String: AnyObject], totalResults = photosDictionary[Flickr.Values.totalResults] as? String else {
                fetchPhotosCompletionHandler(success: false, errorString: Errors.corruptData)
                return
            }
            
            if totalResults == "0" {
                fetchPhotosCompletionHandler(success: false, errorString: Errors.noResults)
            }
            
            //Extract the photo array from the dictioctionary of photos
            guard let photoArray = photosDictionary[Flickr.Values.photo] as? [[String: AnyObject]] else {
                fetchPhotosCompletionHandler(success: false, errorString: Errors.corruptData)
                return
            }
            
            //Extract all photos from the photoArray
            for photoDictionary in photoArray {
                let url = photoDictionary[Flickr.Values.extras] as! String
                let image: NSData = NSData(contentsOfURL: NSURL(string: url)!)!
                let photo = Photo(photo: image, context: self.sharedContext)
                photo.belongsToPin = pin
                
                performUIUpdatesOnMain() {
                    CoreDataStackManager.sharedInstance().saveContext()
                }
            }
            print("Photos fetched")
            fetchPhotosCompletionHandler(success: true, errorString: nil)
        }
        task.resume()
    }
    
    //Create and return a URL to the desired Flickr search page.
    private func createURLWithComponents(latitude latitude: Double, longitude: Double) -> NSURL{
        let urlComponents = NSURLComponents()
        urlComponents.scheme = Flickr.scheme
        urlComponents.host = Flickr.host
        urlComponents.path = Flickr.path
        
        //Add parameters to the URL
        urlComponents.queryItems = [NSURLQueryItem(name: Flickr.Keys.method, value: Flickr.Values.method),
            NSURLQueryItem(name: Flickr.Keys.APIKey, value: Flickr.Values.APIKey),
            NSURLQueryItem(name: Flickr.Keys.latitude, value: "\(latitude)"),
            NSURLQueryItem(name: Flickr.Keys.longitude, value: "\(longitude)"),
            NSURLQueryItem(name: Flickr.Keys.radius, value: Flickr.Values.radius),
            NSURLQueryItem(name: Flickr.Keys.perPage, value: Flickr.Values.perPage),
            NSURLQueryItem(name: Flickr.Keys.extras, value: Flickr.Values.extras),
            NSURLQueryItem(name: Flickr.Keys.format, value: Flickr.Values.format),
            NSURLQueryItem(name: Flickr.Keys.noJSONCallback, value: Flickr.Values.noJSONCallback)]
        print(urlComponents.URL!)
        return urlComponents.URL!
    }
}