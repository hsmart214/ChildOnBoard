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
    func replace(region : COBCircularRegion, with newRegion: COBCircularRegion)
    func updateRegion(_:CLCircularRegion)
    func removeRegion(_:CLCircularRegion)
}

extension CLLocation : MKAnnotation{
    
}

final class EditRegionTVC: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var delegate : EditRegionDelegate?
    let locationManager = CLLocationManager()
    
    let defaultEdge = CLLocationDistance(1250.0)
    var defaultRadius = CLLocationDistance(100.0)
    
    var circle : MKCircle?
    
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
    
    @IBAction func radiusChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            defaultRadius = CLLocationDistance(100.0)
        case 1:
            defaultRadius = CLLocationDistance(200.0)
        case 2:
            defaultRadius = CLLocationDistance(500.0)
        default:
            defaultRadius = CLLocationDistance(100.0)
        }
        let defaults = UserDefaults.standard
        defaults.set(Int(defaultRadius), forKey: Constants.radiusKey)
        if circle != nil{
            let center = circle!.coordinate
            mapView.removeOverlay(circle!)
            circle = MKCircle(center: center, radius: defaultRadius)
            mapView.addOverlay(circle!)
        }
        
    }
    
    func findMyLocation(){
        myLocation = locationManager.location
        if let loc = myLocation{
            mapView.addAnnotation(loc)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if circle != nil{
            mapView.removeOverlay(circle!)
        }
        location = view.annotation!.coordinate
        placemark = view.annotation as? MKPlacemark // this will correctly nil out the placemark if one is not available
        if let name = regionNameTextField.text , name != "" {saveButton.isEnabled = true}
        circle = MKCircle(center: location!, radius: defaultRadius)
        mapView.addOverlay(circle!)
        let span = MKCoordinateRegion.init(center: location!, latitudinalMeters: defaultEdge, longitudinalMeters: defaultEdge)
        mapView.region = span
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle{
            let rend = MKCircleRenderer(circle: overlay as! MKCircle)
            rend.lineWidth = 2.0
            rend.strokeColor = UIColor.COBGreen
            return rend
        }
        return MKCircleRenderer()
    }
    
    //MARK: - Search Bar Delegate
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        cancel(searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        mapView.showsUserLocation = false
        if let addy = searchBar.text{
            var rgn : CLCircularRegion
            if let loc = myLocation?.coordinate{
                rgn = CLCircularRegion(center: loc, radius: CLLocationDistance(15000), identifier: "Search Region")
                geocoder.geocodeAddressString(addy, in: rgn) { places, err in
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == nil {saveButton.isEnabled = false}
        if let text = textField.text {saveButton.isEnabled = (text != "" && location != nil)}
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return region?.identifier ?? "New Region"
        }
        return "Provide a name for this location"
    }
    
    
    @IBAction func locateUser(_ sender: UIBarButtonItem) {
        self.findMyLocation()
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Green"))
        let defaults = UserDefaults.standard
        if let reg = region{
            mapView.showsUserLocation = false
            let span = MKCoordinateRegion.init(center: reg.center, latitudinalMeters: defaultEdge, longitudinalMeters: defaultEdge)
            mapView.region = span
            mapView.addAnnotation(reg.placemark ?? reg)
            regionNameTextField.text = reg.identifier
            saveButton.isEnabled = true
            defaultRadius = reg.radius
            circle = MKCircle(center: reg.center, radius: reg.radius)
            mapView.addOverlay(circle!)
        }else{
            mapView.showsUserLocation = true
            saveButton.isEnabled = false
            defaultRadius = CLLocationDistance(defaults.integer(forKey: Constants.radiusKey))
            if defaultRadius == 0 {
                defaultRadius = CLLocationDistance(100.0)
                defaults.set(defaultRadius, forKey: Constants.radiusKey)
            }
        }
        switch defaultRadius {
        case 100.0:
            self.radiusSegmentedControl.selectedSegmentIndex = 0
        case 200.0:
            self.radiusSegmentedControl.selectedSegmentIndex = 1
        case 500.0:
            self.radiusSegmentedControl.selectedSegmentIndex = 2
        default:
            self.radiusSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    //MARK: - Navigation
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true){}
    }
    
    @IBAction func save(_ sender: AnyObject) {
        if let name = regionNameTextField.text {
            if let loc = location{
                let reg = COBCircularRegion(center: loc, radius: defaultRadius, identifier: name)
                reg.notifyOnExit = true
                reg.notifyOnEntry = false
                reg.placemark = placemark
                self.delegate?.updateRegion(reg)
            }
        }
        self.presentingViewController?.dismiss(animated: true){}
    }
    
}
