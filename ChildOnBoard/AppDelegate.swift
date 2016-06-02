//
//  AppDelegate.swift
//  ChildOnBoard
//
//  Created by J. HOWARD SMART on 5/28/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit
import CoreLocation

struct Constants{
    static let visitCategory = "com.mySmartSoftware.ChildOnBoard.visitCategory"
    static let departureCategory = "com.mySmartSoftware.ChildOnBoard.departureCategory"
    static let companionKey = "com.mySmartSoftware.ChildOnBoard.companionKey"
    static let radiusKey = "com.mySmartSoftware.ChildOnBoard.radiusKey"
    static let archiveFilename = "com.mySmartSoftware.ChildOnBoard.archive"
    static let monitoringRegionsKey = "com.mySmartSoftware.ChildOnBoard.monitoringRegionsKey"
    static let monitoringVisitsKey = "com.mySmartSoftware.ChildOnBoard.monitoringVisitsKey"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var companion = "child"
    var monitoringRegions = false
    var monitoringVisits = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        companion = defaults.stringForKey(Constants.companionKey) ?? companion
        monitoringRegions = defaults.boolForKey(Constants.monitoringRegionsKey)
        monitoringVisits = defaults.boolForKey(Constants.monitoringVisitsKey)
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            self.application(application, didReceiveLocalNotification: notification)
        }
        return true
    }
    
    func registerForLocalUserNotification(){
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: Set(self.notificationCategories()))
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func notificationCategories() -> [UIUserNotificationCategory]{
        let act1 = UIMutableUserNotificationAction()
        act1.title = "Continue Monitoring"
        act1.activationMode = .Background
        act1.identifier = "continue"
        act1.destructive = false
        
        let act2 = UIMutableUserNotificationAction()
        act2.title = "End Trip"
        act2.activationMode = .Background
        act2.identifier = "cancel"
        act2.destructive = true
        
        let cat1 = UIMutableUserNotificationCategory()
        cat1.identifier = Constants.visitCategory
        cat1.setActions([act1, act2], forContext: .Default)
        
        let act3 = UIMutableUserNotificationAction()
        act3.title = "Yes"
        act3.activationMode = .Background
        act3.identifier = "monitor"
        act3.destructive = false
        
        let act4 = UIMutableUserNotificationAction()
        act4.title = "No, thanks"
        act4.activationMode = .Background
        act4.identifier = "denied"
        act4.destructive = true
        
        let cat2 = UIMutableUserNotificationCategory()
        cat2.identifier = Constants.departureCategory
        cat2.setActions([act3, act4], forContext: .Default)
        
        return [cat1, cat2]
    }
    
    func monitorRegions(regions:[CLCircularRegion]){
        
//        UIApplication.sharedApplication().cancelAllLocalNotifications()
//        var notes = [UILocalNotification]()
//        for region in regions{
//            let notification = UILocalNotification()
//            notification.region = region
//            notification.regionTriggersOnce = false
//            notification.soundName = UILocalNotificationDefaultSoundName
//            notification.category = Constants.departureCategory
//            notification.alertTitle = "Starting a Trip?"
//            notification.alertBody = String(format: "Do you have your %@ with you?", self.companion)
//            notes.append(notification)
//        }
//        UIApplication.sharedApplication().scheduledLocalNotifications = notes
        
        //Now for something completely different - use CLLocation Region Monitoring instead of UILocalNotifications
        stopMonitoringAllRegions()
        for region in regions{
            if let reg = region as? COBCircularRegion{
                if reg.currentlyMonitored {locationManager.startMonitoringForRegion(reg)}
            }
        }
        monitoringRegions = true
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: Constants.monitoringRegionsKey)
    }
    
    func stopMonitoringAllRegions(){
        for region in locationManager.monitoredRegions{
            locationManager.stopMonitoringForRegion(region)
        }
        monitoringRegions = false
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: Constants.monitoringRegionsKey)
    }
    
    func monitorVisits(){
        locationManager.startMonitoringVisits()
        monitoringVisits = true
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: Constants.monitoringVisitsKey)
    }
    
    func stopMonitoringVisits(){
        locationManager.stopMonitoringVisits()
        monitoringVisits = false
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: Constants.monitoringVisitsKey)
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if notification.category == Constants.departureCategory{
            print("Regular Local Notification for departure")
        }else if notification.category == Constants.visitCategory{
            print("Regular Local Notification for visit")
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?,
                     forLocalNotification notification: UILocalNotification,
                     completionHandler: () -> Void) {
        if let cat = notification.category, ident = identifier{
            switch cat {
            case Constants.departureCategory:
                switch ident {
                case "denied":
                    stopMonitoringVisits()
                case "monitor":
                    monitorVisits()
                default:
                    break
                }
            case Constants.visitCategory:
                switch ident {
                case "continue":
                    // probably do nothing
                    break
                case "cancel":
                    stopMonitoringVisits()
                default:
                    break
                }
            default:
                break
            }
        }
        completionHandler()
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        let not = UILocalNotification()
        not.alertTitle = "Starting a Trip?"
        not.alertBody = String(format: "Shall I remind you about your %@?", companion)
        not.soundName = UILocalNotificationDefaultSoundName
        not.category = Constants.departureCategory
        UIApplication.sharedApplication().presentLocalNotificationNow(not)
    }
    
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        // This is how you check for an arrival, there is no departure date.
        if visit.departureDate == NSDate.distantFuture(){
            let not = UILocalNotification()
            not.alertTitle = "Trip done?"
            not.alertBody = String(format: "Check the back seat for your %@", companion)
            not.soundName = UILocalNotificationDefaultSoundName
            not.category = Constants.visitCategory
            UIApplication.sharedApplication().presentLocalNotificationNow(not)
        }
    }
}

