//
//  MainTVC.swift
//  ChildOnBoard
//
//  Created by J. HOWARD SMART on 5/28/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

extension CLRegion : MKAnnotation{
    public var coordinate : CLLocationCoordinate2D {
        get {
            return self.coordinate
        }
    }
}

class MainTVC: UITableViewController {

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
