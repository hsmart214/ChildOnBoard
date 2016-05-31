//
//  MainTVC.swift
//  ChildOnBoard
//
//  Created by J. HOWARD SMART on 5/28/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit
import Foundation
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
    var appDelegate : AppDelegate?
    var observer : NSObjectProtocol?
    
    func updateRegion(region: CLCircularRegion) {
        if !monitoredRegions.contains(region){
            monitoredRegions.append(region)
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)){
            if let userDir = NSFileManager.defaultManager().URLsForDirectory(.UserDirectory, inDomains: .UserDomainMask).last{
                let archiveURL = userDir.URLByAppendingPathComponent(Constants.archiveFilename)
                NSKeyedArchiver.archiveRootObject(self.monitoredRegions, toFile: archiveURL.path!)
            }
        }
        self.appDelegate?.monitorRegions(self.monitoredRegions)
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate{
            delegate.registerForLocalUserNotification()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
        case 0,1:
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        case 2,3:
            appDelegate?.locationManager.startMonitoringVisits()
        default:
            break
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let userDir = NSFileManager.defaultManager().URLsForDirectory(.UserDirectory, inDomains: .UserDomainMask).last{
            let archiveURL = userDir.URLByAppendingPathComponent(Constants.archiveFilename)
            monitoredRegions = NSKeyedUnarchiver.unarchiveObjectWithFile(archiveURL.path!) as? [COBCircularRegion] ?? [CLCircularRegion]()
        }
    }
}
