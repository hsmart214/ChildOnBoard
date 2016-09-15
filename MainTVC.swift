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
    // This is the list of all regions which will be persisted
    var monitoredRegions = [CLCircularRegion]()

    weak var appDelegate : AppDelegate?
    @IBOutlet weak var numberOfRegionsLabel: UILabel!
    @IBOutlet weak var visitMonitoringLabel: UILabel!
    @IBOutlet weak var regionMonitoringLabel: UILabel!
    var observer : NSObjectProtocol?
    
    func updateUI(){
        let regs = monitoredRegions as! [COBCircularRegion]
        var n = regs.filter{$0.currentlyMonitored}.count
        if let del = appDelegate{
            if !del.monitoringRegions{ n = 0 }
        }
        numberOfRegionsLabel.text = "\(n) of \(monitoredRegions.count)"
        
        if let del = appDelegate{
            if del.monitoringVisits{
                visitMonitoringLabel.text = NSLocalizedString("Stop Trip Monitoring", comment: "Stop Trip Monitoring")
            }else{
                visitMonitoringLabel.text = NSLocalizedString("Start Trip Monitoring", comment: "Start Trip Monitoring")
            }
            
            if del.monitoringRegions{
                regionMonitoringLabel.text = NSLocalizedString("Stop Region Monitoring", comment: "Stop Region Monitoring")
            }else{
                regionMonitoringLabel.text = NSLocalizedString("Start Region Monitoring", comment: "Start Region Monitoring")
            }
        }
    }
    
    func toggleRegionMonitoring(){        
        if let del = appDelegate{
            if del.monitoringRegions{
                del.stopMonitoringAllRegions()
            }else{
                del.monitorRegions(monitoredRegions)
            }
        }
        updateUI()
    }
    
    func toggleVisitMonitoring(){
        if let del = appDelegate{
            if del.monitoringVisits{
                del.stopMonitoringVisits()
            }else{
                del.monitorVisits()
            }
        }
        updateUI()
    }
    
    func updateRegion(_ region: CLCircularRegion) {
        if !monitoredRegions.contains(region){
            monitoredRegions.append(region)
        }else{
            let i = monitoredRegions.index(of: region)!
            monitoredRegions.replaceSubrange(i..<i+1, with: [region])
        }
        self.appDelegate?.monitorRegions(monitoredRegions)
        archiveRegions()
    }
    
    func removeRegion(_ region: CLCircularRegion) {
        if let index = monitoredRegions.index(of: region){
            monitoredRegions.remove(at: index)
        }
        self.appDelegate?.monitorRegions(monitoredRegions)
        archiveRegions()
    }
    
    func archiveRegions(){
        let mRegions = monitoredRegions // make an immutable copy to pass to the closure
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
            let ud = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            if ud.count != 0{
                let userDir = ud[0]
                let archiveURL = userDir.appendingPathComponent(Constants.archiveFilename)
                NSKeyedArchiver.archiveRootObject(mRegions, toFile: archiveURL.path)
            }
        }
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate{
            delegate.registerForLocalUserNotification()
        }
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath as NSIndexPath).row {
        case 0,1:
            toggleRegionMonitoring()
        case 2,3:
            toggleVisitMonitoring()
        default:
            break
        }
    }
    
    //MARK: - Navigation
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indentifier = segue.identifier{
            switch indentifier{
            case "Region List":
                if let dest = segue.destination.contentViewController as? MonitoredRegionsTVC{
                    dest.monitoredRegions = monitoredRegions
                    dest.delegate = self
                }
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Green"))
        let ud = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if ud.count != 0{
            let userDir = ud[0]
            let archiveURL = userDir.appendingPathComponent(Constants.archiveFilename)
            monitoredRegions = NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? [COBCircularRegion] ?? [CLCircularRegion]()
        }
            
        if appDelegate!.monitoringRegions {
            appDelegate?.monitorRegions(monitoredRegions)
        }else{
            appDelegate?.stopMonitoringAllRegions()
        }
        updateUI()
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil){ [weak self]
            _ in
            DispatchQueue.main.async{
                self?.updateUI()
            }
        }
    }
    
    deinit{
        if observer != nil{
            NotificationCenter.default.removeObserver(observer!)
        }
        observer = nil
    }
}
