//
//  DroppablePin.swift
//  Pixel-City-Map
//
//  Created by Ahmed Waheed on 8/26/18.
//  Copyright © 2018 Ahmed Waheed. All rights reserved.
//  we make that to can drop pin in a map view

import UIKit
import MapKit

class droppablePin : NSObject , MKAnnotation {
    
     dynamic var coordinate :CLLocationCoordinate2D
        var identifier : String
        init(coordinate:CLLocationCoordinate2D , identifier : String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
