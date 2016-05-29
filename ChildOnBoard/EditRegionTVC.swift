//
//  EditRegionTVC.swift
//  BabyReminder
//
//  Created by J. HOWARD SMART on 3/19/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol EditRegionDelegate{
    func updateRegion(_:CLCircularRegion)
}

class EditRegionTVC: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var delegate : EditRegionDelegate?
    
    let defaultEdge = CLLocationDistance(1000)
    let defaultRadius = CLLocationDistance(400)
    
    var region: CLCircularRegion?
    var myLocation : CLLocationCoordinate2D?
    var location : CLLocationCoordinate2D?
    
    var manager : CLLocationManager?
    var geocoder : CLGeocoder?
    
    @IBOutlet weak var regionNameTextField: UITextField!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if ((indexPath.section == 1) && (indexPath.row  == 1)){
            if let cell = tableView.cellForRowAtIndexPath(indexPath){
                if cell.accessoryType == .None{
                    cell.accessoryType = .Checkmark
                }else{
                    cell.accessoryType = .None
                }
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        }
    }
    
    //MARK: Map View Delegate
    
    func findMyLocation(){
        mapView.setUserTrackingMode(.Follow, animated: true)
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        myLocation = userLocation.location?.coordinate
        mapView.region = MKCoordinateRegionMakeWithDistance(myLocation!, defaultEdge, defaultEdge)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        location = view.annotation?.coordinate
    }
    
    
    
    //MARK: Search Bar Delegate
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let addy = searchBar.text{
            var rgn : CLCircularRegion
            if let loc = myLocation{
                rgn = CLCircularRegion(center: loc, radius: CLLocationDistance(15000), identifier: "Search Region")
                geocoder?.geocodeAddressString(addy, inRegion: rgn) { places, err in
                    if places != nil {
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        for place in places!{
                            let mkplace = MKPlacemark(placemark: place)
                            self.mapView.addAnnotation(mkplace)
                        }
                        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                    }
                }
            }else{
                geocoder?.geocodeAddressString(addy){ places, err in
                    if places != nil {
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        for place in places!{
                            let mkplace = MKPlacemark(placemark: place)
                            self.mapView.addAnnotation(mkplace)
                        }
                        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                    }
                }
            }
        }
    }
    //MARK: Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Location Manager Delegate
    
    @IBAction func locateUser(sender: UIBarButtonItem) {
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if manager == nil {
            manager = CLLocationManager()
        }
        manager?.delegate = self
        
        geocoder = CLGeocoder()
        if let reg = region{
            mapView.showsUserLocation = false
            let span = MKCoordinateRegionMakeWithDistance(reg.center, defaultEdge, defaultEdge)
            mapView.region = span
            mapView.addAnnotation(reg)
            regionNameTextField.text = reg.identifier
        }else{
            mapView.showsUserLocation = true
        }
    }
    
    //MARK: Navigation
    @IBAction func cancel(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true){}
    }
    
    @IBAction func save(sender: AnyObject) {
        if let name = regionNameTextField.text{
            if let loc = location{
                let reg = CLCircularRegion(center: loc, radius: defaultRadius, identifier: name)
                self.delegate?.updateRegion(reg)
            }
        }
        self.presentingViewController?.dismissViewControllerAnimated(true){}
    }
    
}
