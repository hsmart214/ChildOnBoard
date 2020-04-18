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
    static let arrivalCategory = "com.mySmartSoftware.ChildOnBoard.arrivalCategory"
    static let companionKey = "com.mySmartSoftware.ChildOnBoard.companionKey"
    static let radiusKey = "com.mySmartSoftware.ChildOnBoard.radiusKey"
    static let archiveFilename = "com.mySmartSoftware.ChildOnBoard.archive"
    static let monitoringRegionsKey = "com.mySmartSoftware.ChildOnBoard.monitoringRegionsKey"
    static let monitoringVisitsKey = "com.mySmartSoftware.ChildOnBoard.monitoringVisitsKey"
    static let redundantNoticePreferenceKey = "com.mySmartSoftware.ChildOnBoard.redundantNoticePreferenceKey"
    static let mapTypePreferenceKey = "com.mySmartSoftware.ChildOnBoard.mapTypePreferenceKey"
}

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var companion = "child"
    var monitoringRegions = false
    var monitoringVisits = false
    var postRedundantNotices = true
    var regionMonitoringOnAtStart = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let defaults = UserDefaults.standard
        companion = defaults.string(forKey: Constants.companionKey) ?? companion
        monitoringRegions = defaults.bool(forKey: Constants.monitoringRegionsKey)
        monitoringVisits = defaults.bool(forKey: Constants.monitoringVisitsKey)
        if defaults.value(forKey: Constants.redundantNoticePreferenceKey) == nil{
            defaults.set(true, forKey: Constants.redundantNoticePreferenceKey)
        }else{
            postRedundantNotices = defaults.bool(forKey: Constants.redundantNoticePreferenceKey)
        }
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        if let notification = launchOptions?[UIApplication.LaunchOptionsKey.localNotification] as? UILocalNotification {
            self.application(application, didReceive: notification)
        }
        return true
    }
    
    func registerForLocalUserNotification(){
        let settings = UIUserNotificationSettings(types: [.alert, .sound], categories: Set(self.notificationCategories()))
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    func notificationCategories() -> [UIUserNotificationCategory]{
        let act1 = UIMutableUserNotificationAction()
        act1.title = "Continue Monitoring"
        act1.activationMode = .background
        act1.identifier = "continue"
        act1.isDestructive = false
        
        let act2 = UIMutableUserNotificationAction()
        act2.title = "End Trip"
        act2.activationMode = .background
        act2.identifier = "cancel"
        act2.isDestructive = true
        
        let cat1 = UIMutableUserNotificationCategory()
        cat1.identifier = Constants.visitCategory
        cat1.setActions([act1, act2], for: .default)
        
        let act3 = UIMutableUserNotificationAction()
        act3.title = "Yes"
        act3.activationMode = .background
        act3.identifier = "monitor"
        act3.isDestructive = false
        
        let act4 = UIMutableUserNotificationAction()
        act4.title = "No, thanks"
        act4.activationMode = .background
        act4.identifier = "denied"
        act4.isDestructive = true
        
        let cat2 = UIMutableUserNotificationCategory()
        cat2.identifier = Constants.departureCategory
        cat2.setActions([act3, act4], for: .default)
        
        let act5 = UIMutableUserNotificationAction()
        act5.title = "Dismiss"
        act5.activationMode = .background
        act5.identifier = "dismissed"
        act5.isDestructive = false
        
        let cat3 = UIMutableUserNotificationCategory()
        cat3.identifier = Constants.arrivalCategory
        //cat3.setActions([act5], for: .default)
        
        return [cat1, cat2, cat3]
    }
    
    func monitorRegions(_ regions:[CLCircularRegion]){
        stopMonitoringAllRegions()
        for region in regions{
            if let reg = region as? COBCircularRegion{
                if reg.currentlyMonitored {locationManager.startMonitoring(for: reg)}
            }
        }
        monitoringRegions = true
        UserDefaults.standard.set(true, forKey: Constants.monitoringRegionsKey)
        //        printMonitored(regions: regions)
    }
    
//    func printMonitored(regions:[COBCircularRegion]){
//        for region in regions{
//            let curr = String(region.currentlyMonitored)
//            let entry = String(region.notifyOnEntry)
//            let exit = String(region.notifyOnExit)
//            let msg = String.localizedStringWithFormat("Region name: %@, currently monitored: %@, arrival: %@, departure: %@", region.identifier, curr, entry, exit)
//            print(msg)
//            
//        }
//    }
    
    func stopMonitoringAllRegions(){
        for region in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: region)
        }
        monitoringRegions = false
        UserDefaults.standard.set(false, forKey: Constants.monitoringRegionsKey)
    }
    
    func monitorVisits(){
        locationManager.startMonitoringVisits()
        monitoringVisits = true
        UserDefaults.standard.set(true, forKey: Constants.monitoringVisitsKey)
    }
    
    func stopMonitoringVisits(){
        locationManager.stopMonitoringVisits()
        monitoringVisits = false
        UserDefaults.standard.set(false, forKey: Constants.monitoringVisitsKey)
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if notification.category == Constants.departureCategory{
            print("Regular Local Notification for departure")
        }else if notification.category == Constants.visitCategory{
            print("Regular Local Notification for visit")
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?,
                     for notification: UILocalNotification,
                     completionHandler: @escaping () -> Void) {
        if let cat = notification.category, let ident = identifier{
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
            case Constants.arrivalCategory:
                // since the only action is to dismiss
                // there is nothing to do here
                break
            default:
                break
            }
        }
        completionHandler()
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if monitoringVisits && !postRedundantNotices { return }// per the user's preference
        let not = UILocalNotification()
        not.alertTitle = "Starting a Trip?"
        not.alertBody = String(format: "Shall I remind you about your %@?", companion)
        not.soundName = UILocalNotificationDefaultSoundName
        not.category = Constants.departureCategory
        UIApplication.shared.presentLocalNotificationNow(not)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let not = UILocalNotification()
        not.alertTitle = String(format: "Arrived at %@", region.identifier)
        not.alertBody = String(format: "Check the back seat for your %@.", companion)
        not.soundName = UILocalNotificationDefaultSoundName
        not.category = Constants.arrivalCategory
        UIApplication.shared.presentLocalNotificationNow(not)
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // This is how you check for an arrival, there is no departure date.
        if visit.departureDate == Date.distantFuture{
            let not = UILocalNotification()
            not.alertTitle = "Trip done?"
            not.alertBody = String(format: "Check the back seat for your %@", companion)
            not.soundName = UILocalNotificationDefaultSoundName
            not.category = Constants.visitCategory
            UIApplication.shared.presentLocalNotificationNow(not)
        }
    }
}

