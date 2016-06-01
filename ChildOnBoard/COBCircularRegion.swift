//
//  COBCircularRegion.swift
//  ChildOnBoard
//
//  Created by J. HOWARD SMART on 5/30/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class COBCircularRegion: CLCircularRegion {
    
    var placemark : MKPlacemark?
    var currentlyMonitored = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        placemark = aDecoder.decodeObjectForKey("placemark") as? MKPlacemark
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(placemark, forKey: "placemark")
        super.encodeWithCoder(aCoder)
    }
    
    override init(center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        super.init(center: center, radius: radius, identifier: identifier)
    }

}
