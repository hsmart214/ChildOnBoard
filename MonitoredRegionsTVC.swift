//
//  MonitoredRegionsTVC.swift
//  ChildOnBoard
//
//  Created by J. HOWARD SMART on 5/28/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit
import CoreLocation

class MonitoredRegionsTVC: UITableViewController, EditRegionDelegate {
    
    var monitoredRegions = [CLCircularRegion]()
    var delegate : EditRegionDelegate?

    func updateRegion(region: CLCircularRegion){
        if !monitoredRegions.contains(region){
            monitoredRegions.append(region)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Region Cell", forIndexPath: indexPath)
        cell.textLabel?.text = monitoredRegions[indexPath.row].identifier
        cell.detailTextLabel?.text = "\(monitoredRegions[indexPath.row].radius) m"
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
}
