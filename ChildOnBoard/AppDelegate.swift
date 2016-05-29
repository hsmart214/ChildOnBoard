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
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()

    func registerForLocalUserNotification(){
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: [self.notificationCategories()])
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func notificationCategories() -> UIUserNotificationCategory{
        let act1 = UIMutableUserNotificationAction()
        act1.title = "Action 1"
        act1.activationMode = .Foreground
        act1.identifier = "ident1"
        act1.destructive = false
        
        let act2 = UIMutableUserNotificationAction()
        act2.title = "Action 2"
        act2.activationMode = .Background
        act2.identifier = "ident2"
        act2.destructive = true
        
        let act3 = UIMutableUserNotificationAction()
        act3.title = "Action 3"
        act3.activationMode = .Background
        act3.identifier = "ident3"
        act3.destructive = false
        
        let cat = UIMutableUserNotificationCategory()
        cat.identifier = Constants.visitCategory
        cat.setActions([act1, act3], forContext: .Minimal)
        cat.setActions([act1, act2, act3], forContext: .Default)
        
        return cat
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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


}

