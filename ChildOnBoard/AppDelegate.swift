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
    static let archiveFilename = "com.mySmartSoftware.ChildOnBoard.archive"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var companion = "child"

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
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)){
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            for region in regions{
                let notification = UILocalNotification()
                notification.region = region
                notification.regionTriggersOnce = false
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.category = Constants.departureCategory
                notification.alertTitle = "Starting a Trip?"
                notification.alertBody = String(format: "Do you have your %@ with you?", self.companion)
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        companion = defaults.stringForKey(Constants.companionKey) ?? companion
        locationManager.delegate = self
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            self.application(application, didReceiveLocalNotification: notification)
        }
        return true
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if notification.category == Constants.departureCategory{
            print("Regular Local Notification for departure")
        }else if notification.category == Constants.visitCategory{
            print("Regular Local Notification for visit")
        }
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types == .None{
            print ("Local Notifications denied")
        }else{
            print ("Successfully registered for local notifications")
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
                    // probably do nothing
                    break
                case "monitor":
                    locationManager.startMonitoringVisits()
                default:
                    break
                }
            case Constants.visitCategory:
                switch ident {
                case "continue":
                    // probably do nothing
                    break
                case "cancel":
                    locationManager.stopMonitoringVisits()
                default:
                    break
                }
            default:
                break
            }
        }
        completionHandler()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        // This is how you check for an arrival, there is no departure.
        if visit.departureDate == NSDate.distantFuture(){
            let not = UILocalNotification()
            not.alertTitle = "Trip done?"
            not.alertBody = String(format: "Check the back seat for your %@", companion)
            not.soundName = UILocalNotificationDefaultSoundName
            not.category = Constants.visitCategory
            UIApplication.sharedApplication().presentLocalNotificationNow(not)
        }// for now we will ignore departures and simply wait for the next visit
    }
}

