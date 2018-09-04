//
//  Constants.swift
//  Pixel-City-Map
//
//  Created by Ahmed Waheed on 8/28/18.
//  Copyright © 2018 Ahmed Waheed. All rights reserved.
//

import Foundation

// API key
let apiKey = "176b466b9a5fc8e02001b9e9fd9b6399"

// we made it to pass data in it
func flickrUrl(forApiKey key:String , withAnnotation annotation:droppablePin ,andNumberOfPhotos number:Int) -> String {
   let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}
