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

extension CLCircularRegion : MKAnnotation{
    public var coordinate : CLLocationCoordinate2D{
        get{
            return center
        }
    }
    public var title : String?{
        get{
            return identifier
        }
    }
}

extension UIViewController{
    public var contentViewController : UIViewController {
        get{
            if let nav = self as? UINavigationController{
                return nav.visibleViewController!
            }else{
                return self
            }
        }
    }
}

class MainTVC: UITableViewController, EditRegionDelegate {
    
    var monitoredRegions = [CLCircularRegion]()
    
    func updateRegion(region: CLCircularRegion) {
        if !monitoredRegions.contains(region){
            monitoredRegions.append(region)
        }
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate{
            delegate.registerForLocalUserNotification()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: - Navigation
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indentifier = segue.identifier{
            switch indentifier{
            case "Region List":
                if let dest = segue.destinationViewController.contentViewController as? MonitoredRegionsTVC{
                    dest.monitoredRegions = monitoredRegions
                    dest.delegate = self
                }
            default:
                break
            }
        }
    }
    
}
