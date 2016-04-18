//
//  FlickrSearch.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 16/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import Foundation

public class FlickrSearch {
    
    //Shared class instance.
    private static var sharedInstance = FlickrSearch()
    class func sharedFlickrSearchInstance() -> FlickrSearch {
        return sharedInstance
    }
    
    //Fetch a photo array from Flickr search results
    func fetchPhotos(latitude latitude: Double, longitude: Double, fetchPhotosCompletionHandler: (success: Bool, errorString: String?, imageArray: [NSData]?) -> Void) {
        let queryURL = createURLWithComponents(latitude: latitude, longitude: longitude)
        let request = NSURLRequest(URL: queryURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error)  in
            
            if error != nil {
                fetchPhotosCompletionHandler(success: false, errorString: Errors.internetConnection, imageArray: nil)
                return
            }
            
            //Parse the serialised JSON data
            let parsedData: AnyObject!
            do {
                parsedData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                fetchPhotosCompletionHandler(success: false, errorString: Errors.corruptData, imageArray: nil)
                return
            }
            
            //Extract dictionary of photos
            guard let photosDictionary = parsedData[Flickr.Values.photos] as? [String: AnyObject] else {
                fetchPhotosCompletionHandler(success: false, errorString: Errors.corruptData, imageArray: nil)
                return
            }
            
            //Extract the photo array from the dictioctionary of photos
            guard let photoArray = photosDictionary[Flickr.Values.photo] as? [[String: AnyObject]] else {
                fetchPhotosCompletionHandler(success: false, errorString: Errors.corruptData, imageArray: nil)
                return
            }
            
            var imageArray = [NSData]()
            
            //Extract all photos from the photoArray
            for photoDictionary in photoArray {
                let url = photoDictionary[Flickr.Values.extras] as! String
                let image: NSData = NSData(contentsOfURL: NSURL(string: url)!)!
                imageArray.append(image)
            }
            
            print("Photos fetched")
            fetchPhotosCompletionHandler(success: true, errorString: nil, imageArray: imageArray)
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
        
        return urlComponents.URL!
    }
}