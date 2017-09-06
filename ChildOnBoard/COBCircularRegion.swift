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

final class COBCircularRegion: CLCircularRegion {
    
    var placemark : MKPlacemark?
    var currentlyMonitored = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        placemark = aDecoder.decodeObject(forKey: "placemark") as? MKPlacemark
        currentlyMonitored = aDecoder.decodeBool(forKey: "currentlyMonitored")
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(placemark, forKey: "placemark")
        aCoder.encode(currentlyMonitored, forKey: "currentlyMonitored")
        super.encode(with: aCoder)
    }
    
    override init(center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        super.init(center: center, radius: radius, identifier: identifier)
    }

}
