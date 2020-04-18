//  MonitoredRegionsTVC.swift
//
//  ChildOnBoard
//
//  Created by J. HOWARD SMART on 5/28/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

final class MonitoredRegionsTVC: UITableViewController, EditRegionDelegate, RegionCellDelegate {
    
    var monitoredRegions = [CLCircularRegion]()
    var delegate : EditRegionDelegate?
    var mapType : MKMapType = .standard
    
    func toggleEntryForRegion(_ region: COBCircularRegion) {
        region.notifyOnEntry = !region.notifyOnEntry
        updateRegion(region)
        tableView.reloadData()
    }
    
    func toggleExitForRegion(_ region: COBCircularRegion) {
        region.notifyOnExit = !region.notifyOnExit
        updateRegion(region)
        tableView.reloadData()
    }
    
    func toggleMonitoringForRegion(_ region : COBCircularRegion){
        region.currentlyMonitored = !region.currentlyMonitored
        updateRegion(region)
        tableView.reloadData()
    }
    // This delegate call back is necessary because the radius of a CLCircularRegion is immutable.
    // Every time you want to change the radius, you have to create a new copy of the Region and release the old one.
    func change(radius: CLLocationDistance, forRegion region: COBCircularRegion, forCell cell: RegionCell) {
        let newRegion = COBCircularRegion(center: region.center,
                                          radius: radius,
                                          identifier: region.identifier)
        newRegion.notifyOnExit = region.notifyOnExit
        newRegion.notifyOnEntry = region.notifyOnEntry
        newRegion.currentlyMonitored = region.currentlyMonitored
        newRegion.placemark = region.placemark
        replace(region: region, with: newRegion) // now the only reference to the old region should be this local parameter
        cell.region = newRegion // this will trigger the whole didSet on the RegionCell
        tableView.reloadData()
    }
    
    func replace(region : COBCircularRegion, with newRegion: COBCircularRegion){
        if let index = monitoredRegions.firstIndex(of: region){
//            monitoredRegions.remove(at: index)
//            monitoredRegions.insert(newRegion, at: index)
            monitoredRegions[index] = newRegion
        }
        delegate?.replace(region: region, with: newRegion)
    }

    func updateRegion(_ region: CLCircularRegion){
        if !monitoredRegions.contains(region){
            monitoredRegions.append(region)
        }
        delegate?.updateRegion(region)
    }
    
    func removeRegion(_ region: CLCircularRegion){
        if let index = monitoredRegions.firstIndex(of: region){
            monitoredRegions.remove(at: index)
        }
        delegate?.removeRegion(region)
    }
    
    func changeMapTypePreferenceTo(_ mapTypePreference : MKMapType){
        let defaults = UserDefaults.standard
        defaults.set(Int(mapTypePreference.rawValue), forKey: Constants.mapTypePreferenceKey)
        defaults.synchronize()
    }
    
    @IBAction func changeMapType(_ sender: Any) {
        let oldMapType = mapType
        let action1 = UIAlertAction(title: "Standard",
                                   style: .default)
        {(act : UIAlertAction) in
            self.mapType = .standard
            if self.mapType != oldMapType{
                self.changeMapTypePreferenceTo(self.mapType)
                self.tableView.reloadData()
            }
        }
        let action2 = UIAlertAction(title: "Satellite",
                                    style: .default)
        {(act : UIAlertAction) in
            self.mapType = .satellite
            if self.mapType != oldMapType{
                self.changeMapTypePreferenceTo(self.mapType)
                self.tableView.reloadData()
            }
        }
        let action3 = UIAlertAction(title: "Hybrid",
                                    style: .default)
        {(act : UIAlertAction) in
            self.mapType = .hybrid
            if self.mapType != oldMapType{
                self.changeMapTypePreferenceTo(self.mapType)
                self.tableView.reloadData()
            }
        }
        let action4 = UIAlertAction(title: "Cancel",
                                    style: .cancel,
                                    handler: nil)
        
        let alert = UIAlertController(title: "Map Type",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action4)
        
        present(alert, animated: true, completion: nil)
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
        cell.delegate = self
        cell.mapView.mapType = self.mapType
        cell.region = monitoredRegions[(indexPath as NSIndexPath).row] as? COBCircularRegion
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        let defaults = UserDefaults.standard
        if let mapPref = MKMapType(rawValue: UInt(defaults.integer(forKey: Constants.mapTypePreferenceKey))){
            mapType = mapPref
        }
        self.tableView.reloadData()
    }
}
