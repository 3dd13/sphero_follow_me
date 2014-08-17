//
//  AppDelegate.swift
//  SpheroFollowMe
//
//  Created by Eddie Lau on 17/8/14.
//  Copyright (c) 2014 42 Labs. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var locationManager: CLLocationManager?
    var robotOnline: Bool?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        setupLocationManager(application)
        connectToSphero()
        
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

    func setupLocationManager(application: UIApplication) {
        // TODO get list of UUID from backend database
        let uuidString = "D3D1F3CF-976F-43EE-A4E9-EF6C67745275"
        let beaconIdentifier = "jollan.cn"
        let beaconUUID:NSUUID = NSUUID(UUIDString: uuidString)
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier: beaconIdentifier)
        
        locationManager = CLLocationManager()
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager!.requestAlwaysAuthorization()
        }
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        locationManager!.startMonitoringForRegion(beaconRegion)
        locationManager!.startRangingBeaconsInRegion(beaconRegion)
        locationManager!.startUpdatingLocation()
    }
    
    func connectToSphero() {
        NSLog("connectToSphero")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleRobotOnline", name: RKDeviceConnectionOnlineNotification, object: nil)
        
        NSLog("connectToSphero \(RKRobotProvider.sharedRobotProvider().isRobotUnderControl())")
        if (RKRobotProvider.sharedRobotProvider().isRobotUnderControl()) {
            RKRobotProvider.sharedRobotProvider().openRobotConnection()
        } else {
            RKRobotProvider.sharedRobotProvider().controlConnectedRobot()
        }
    }
    
    func handleRobotOnline() {
        if(!robotOnline) {
          /* Send commands to Sphero Here: */
          RKRGBLEDOutputCommand.sendCommandWithRed(1.0, green: 0.0, blue: 0.0)
        }
        robotOnline = true;
    }
}


extension AppDelegate: CLLocationManagerDelegate {
    func performStop() {
        RKRollCommand.sendStop()
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: AnyObject[]!, inRegion region: CLBeaconRegion!) {
        NSLog("didRangeBeacons \(beacons.count)")
        let detectedBeacons = beacons as CLBeacon[]?
        
        for detectedBeacon in detectedBeacons! {
            NSLog("RSSI \(detectedBeacon.rssi)")
            
            if (detectedBeacon.rssi < -55) {
                RKRollCommand.sendCommandWithHeading(0.0, velocity:0.2)
            } else {
                NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("performStop"), userInfo: nil, repeats: false)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        manager.startRangingBeaconsInRegion(region as CLBeaconRegion)
        manager.startUpdatingLocation()
        
        NSLog("You entered the region")
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        manager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
        manager.stopUpdatingLocation()
        
        NSLog("You exited the region")
    }
}