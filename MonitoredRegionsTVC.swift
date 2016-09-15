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
    
    func toggleMonitoringForRegion(_ region : COBCircularRegion){
        region.currentlyMonitored = !region.currentlyMonitored
        tableView.reloadData()
        updateRegion(region)
    }

    func updateRegion(_ region: CLCircularRegion){
        if !monitoredRegions.contains(region){
            monitoredRegions.append(region)
        }else{
            let i = monitoredRegions.index(of: region)!
            monitoredRegions.replaceSubrange(i..<i+1, with: [region])
        }
        delegate?.updateRegion(region)
    }
    
    func removeRegion(_ region: CLCircularRegion){
        delegate?.removeRegion(region)
    }
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monitoredRegions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Region Cell", for: indexPath) as! RegionCell
        cell.region = monitoredRegions[(indexPath as NSIndexPath).row] as? COBCircularRegion
        cell.delegate = self
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.beginUpdates()
            delegate?.removeRegion(monitoredRegions[(indexPath as NSIndexPath).row])
            monitoredRegions.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, let dest = segue.destination.contentViewController as? EditRegionTVC {
            switch identifier {
            case "Edit Region":
                dest.delegate = self
                if let cell = sender as? UITableViewCell, let index = (self.tableView.indexPath(for: cell) as NSIndexPath?)?.row{
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
}
