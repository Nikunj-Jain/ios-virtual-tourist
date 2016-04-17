//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 16/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import Foundation

struct Flickr {
    
    static let scheme = "https"
    static let host = "api.flickr.com"
    static let path = "/services/rest"
    
    struct Keys {
        static let method = "method"
        static let APIKey = "api_key"
        static let format = "format"
        static let extras = "extras"
        static let latitude = "lat"
        static let longitude = "lon"
        static let radius = "radius"
        static let perPage = "per_page"
        static let pageNumber = "page"
        static let noJSONCallback = "nojsoncallback"
    }
    
    struct Values {
        static let method = "flickr.photos.search"
        static let APIKey = "0cda9b4059b8847967abe52d22efd6fb"
        static let format = "json"
        static let extras = "url_s"
        static let radius = "3"
        static let perPage = "30"
        static let noJSONCallback = "1"
    }
}