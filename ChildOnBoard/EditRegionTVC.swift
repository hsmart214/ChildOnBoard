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
    func removeRegion(_:CLCircularRegion)
}

extension CLLocation : MKAnnotation{
    
}

class EditRegionTVC: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var delegate : EditRegionDelegate?
    let locationManager = CLLocationManager()
    
    let defaultEdge = CLLocationDistance(1000)
    var defaultRadius = CLLocationDistance(100)
    
    var region: COBCircularRegion?{
        didSet{
            placemark = region?.placemark
            location = region?.center
        }
    }
    var myLocation : CLLocation?
    var location : CLLocationCoordinate2D?
    var placemark : MKPlacemark?
    
    var geocoder = CLGeocoder()
    
    @IBOutlet weak var regionNameTextField: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var radiusSegmentedControl: UISegmentedControl!
    
    //MARK: - Map View Delegate
    
    @IBAction func radiusChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            defaultRadius = 100
        case 1:
            defaultRadius = 200
        case 2:
            defaultRadius = 500
        default:
            defaultRadius = 100
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(Int(defaultRadius), forKey: Constants.radiusKey)
    }
    
    func findMyLocation(){
        myLocation = locationManager.location
        if let loc = myLocation{
            mapView.addAnnotation(loc)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        location = view.annotation?.coordinate
        placemark = view.annotation as? MKPlacemark // this will correctly nil out the placemark if one is not available
        if let name = regionNameTextField.text where name != "" {saveButton.enabled = true}
    }
    
    //MARK: - Search Bar Delegate
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        cancel(searchBar)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        mapView.showsUserLocation = false
        if let addy = searchBar.text{
            var rgn : CLCircularRegion
            if let loc = myLocation?.coordinate{
                rgn = CLCircularRegion(center: loc, radius: CLLocationDistance(15000), identifier: "Search Region")
                geocoder.geocodeAddressString(addy, inRegion: rgn) { places, err in
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
                geocoder.geocodeAddressString(addy){ places, err in
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
    //MARK: - Text Field Delegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text == nil {saveButton.enabled = false}
        if let text = textField.text {saveButton.enabled = (text != "" && location != nil)}
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return region?.identifier ?? "New Region"
        }
        return "Provide a name for this location"
    }
    
    
    @IBAction func locateUser(sender: UIBarButtonItem) {
        self.findMyLocation()
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Green"))
        let defaults = NSUserDefaults.standardUserDefaults()
        if let reg = region{
            mapView.showsUserLocation = false
            let span = MKCoordinateRegionMakeWithDistance(reg.center, defaultEdge, defaultEdge)
            mapView.region = span
            mapView.addAnnotation(reg.placemark ?? reg)
            regionNameTextField.text = reg.identifier
            saveButton.enabled = true
            defaultRadius = reg.radius
        }else{
            mapView.showsUserLocation = true
            saveButton.enabled = false
            defaultRadius = CLLocationDistance(defaults.integerForKey(Constants.radiusKey))
            if defaultRadius == 0 {
                defaultRadius = 100
                defaults.setInteger(100, forKey: Constants.radiusKey)
            }
        }
        switch defaultRadius {
        case 100:
            self.radiusSegmentedControl.selectedSegmentIndex = 0
        case 200:
            self.radiusSegmentedControl.selectedSegmentIndex = 1
        case 500:
            self.radiusSegmentedControl.selectedSegmentIndex = 2
        default:
            self.radiusSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    //MARK: - Navigation
    
    @IBAction func cancel(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true){}
    }
    
    @IBAction func save(sender: AnyObject) {
        if let name = regionNameTextField.text {
            if let loc = location{
                let reg = COBCircularRegion(center: loc, radius: defaultRadius, identifier: name)
                reg.notifyOnExit = true
                reg.notifyOnEntry = false
                reg.placemark = placemark
                self.delegate?.updateRegion(reg)
            }
        }
        self.presentingViewController?.dismissViewControllerAnimated(true){}
    }
    
}
