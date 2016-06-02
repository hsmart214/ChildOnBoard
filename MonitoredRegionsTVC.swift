//
//  MonitoredRegionsTVC.swift
//  ChildOnBoard
//
//  Created by J. HOWARD SMART on 5/28/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit
import CoreLocation

class MonitoredRegionsTVC: UITableViewController, EditRegionDelegate, RegionCellDelegate {
    
    var monitoredRegions = [CLCircularRegion]()
    var delegate : EditRegionDelegate?
    
    func toggleMonitoringForRegion(region : COBCircularRegion){
        region.currentlyMonitored = !region.currentlyMonitored
        tableView.reloadData()
        updateRegion(region)
    }

    func updateRegion(region: CLCircularRegion){
        if !monitoredRegions.contains(region){
            monitoredRegions.append(region)
        }else{
            let i = monitoredRegions.indexOf(region)!
            monitoredRegions.replaceRange(i..<i+1, with: [region])
        }
        delegate?.updateRegion(region)
    }
    
    func removeRegion(region: CLCircularRegion){
        delegate?.removeRegion(region)
    }
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monitoredRegions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Region Cell", forIndexPath: indexPath) as! RegionCell
        cell.region = monitoredRegions[indexPath.row] as? COBCircularRegion
        cell.delegate = self
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            tableView.beginUpdates()
            delegate?.removeRegion(monitoredRegions[indexPath.row])
            monitoredRegions.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier, dest = segue.destinationViewController.contentViewController as? EditRegionTVC {
            switch identifier {
            case "Edit Region":
                dest.delegate = self
                if let cell = sender as? UITableViewCell, index = self.tableView.indexPathForCell(cell)?.row{
                    dest.region = monitoredRegions[index] as? COBCircularRegion
                }
            case "Add Region":
                dest.delegate = self
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Green"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
}
