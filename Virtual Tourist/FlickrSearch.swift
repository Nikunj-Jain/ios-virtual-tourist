//
//  FlickrSearch.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 16/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import Foundation

public class FlickrSearch {
    
    private static var sharedInstance = FlickrSearch()
    
    class func sharedFlickrSearchInstance() -> FlickrSearch {
        return sharedInstance
    }
    
    private func createURLWithComponents(latitude latitude: Double, longitude: Double) -> NSURL{
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = Flickr.scheme
        urlComponents.host = Flickr.host
        urlComponents.path = Flickr.path
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
    
    func fetchPhotos(latitude latitude: Double, longitude: Double, fetchPhotosCompletionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let queryURL = createURLWithComponents(latitude: latitude, longitude: longitude)
        let request = NSURLRequest(URL: queryURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error)  in
            
            if error != nil {
                fetchPhotosCompletionHandler(success: false, errorString: "Could not connect to Flickr. Please check internet connection.")
                return
            }
            
            let parsedData: AnyObject!
            do {
                parsedData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                fetchPhotosCompletionHandler(success: false, errorString: "Data from Flickr is corrupted. Please try again.")
                return
            }
            print(parsedData)
        }
        
        task.resume()
    }
}