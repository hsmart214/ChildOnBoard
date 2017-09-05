//
//  RegionCell.swift
//  ChildOnBoard
//
//  Created by J. HOWARD SMART on 6/1/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit
import MapKit

protocol RegionCellDelegate{
    func toggleMonitoringForRegion(_:COBCircularRegion)
    func toggleEntryForRegion(_:COBCircularRegion)
    func toggleExitForRegion(_:COBCircularRegion)
    var mapType : MKMapType {get}
}

class RegionCell: UITableViewCell, MKMapViewDelegate {
    
    var delegate : RegionCellDelegate?
    
    var renderer : MKCircleRenderer?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    
    @IBOutlet weak var enabledSwitch: UISwitch!
    @IBOutlet weak var notifyEntrySwitch: UISwitch!
    @IBOutlet weak var notifyExitSwitch: UISwitch!
    
    @IBOutlet weak var enabledButton: UIButton!
    @IBOutlet weak var entryButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func enableButtonTap() {
        enabledSwitch.setOn(!enabledSwitch.isOn, animated: true)
        toggleEnabled()
    }
    
    @IBAction func entryButtonTapped() {
        notifyEntrySwitch.setOn(!notifyEntrySwitch.isOn, animated: true)
        toggleNotifyOnEntry()
    }
    
    @IBAction func exitButtonTapped() {
        notifyExitSwitch.setOn(!notifyExitSwitch.isOn, animated: true)
        toggleNotifyExit()
    }
    
    @IBAction func toggleEnabled() {
        //Swift.print("toggleEnabled")
        if region != nil{
            if region!.currentlyMonitored{
                region!.currentlyMonitored = false
                entryButton.isEnabled = false
                notifyEntrySwitch.isEnabled = false
                exitButton.isEnabled = false
                notifyExitSwitch.isEnabled = false
            }else{
                region!.currentlyMonitored = true
                entryButton.isEnabled = true
                notifyEntrySwitch.isEnabled = true
                exitButton.isEnabled = true
                notifyExitSwitch.isEnabled = true
            }
        }
    }

    @IBAction func toggleNotifyExit() {
        if region != nil{
            delegate?.toggleExitForRegion(region!)
        }
    }
    
    @IBAction func toggleNotifyOnEntry(){
        if region != nil{
            delegate?.toggleEntryForRegion(region!)
        }
    }
    
    
    var region : COBCircularRegion? {
        didSet {
            nameLabel.text = region?.identifier
            let rad = region?.radius ?? 0.0
            radiusLabel.text = "\(Int(rad)) m"
            for overlay in mapView.overlays{
                mapView.remove(overlay)
            }
            for annot in mapView.annotations{
                mapView.removeAnnotation(annot)
            }
            
            if region != nil{
                notifyExitSwitch.setOn(region!.notifyOnExit, animated: false)
                notifyEntrySwitch.setOn(region!.notifyOnEntry, animated: false)
                if region!.currentlyMonitored{
                    enabledSwitch.setOn(true, animated: false)
                    entryButton.isEnabled = true
                    notifyEntrySwitch.isEnabled = true
                    exitButton.isEnabled = true
                    notifyExitSwitch.isEnabled = true
                }else{
                    enabledSwitch.setOn(false, animated: false)
                    entryButton.isEnabled = false
                    notifyEntrySwitch.isEnabled = false
                    exitButton.isEnabled = false
                    notifyExitSwitch.isEnabled = false
                }
                // Set the map location and size of area displayed
                mapView.mapType = delegate?.mapType ?? .standard
                if let pm = region!.placemark {
                    mapView.addAnnotation(pm)
                    mapView.showAnnotations([pm], animated: false)
                    let span = MKCoordinateRegionMakeWithDistance(region!.center, rad*2.5, rad*2.5)
                    mapView.region = span
                    // Draw a circle for the monitored radius
                    let circ = MKCircle(center: pm.coordinate, radius: rad)
                    mapView.add(circ)
                }
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle{
            let rend = MKCircleRenderer(circle: overlay as! MKCircle)
            rend.strokeColor = UIColor.blue
            rend.lineWidth = 1.0
            return rend
        }
        return MKCircleRenderer()
    }
}
