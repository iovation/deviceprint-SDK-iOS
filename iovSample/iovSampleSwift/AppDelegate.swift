//
//  AppDelegate.swift
//  iovSampleSwift
//
//  Copyright © 2017-2020 iovation, Inc. All rights reserved.
//

import CoreLocation
import FraudForce
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            // The app is authorized to track the device location. FraudForce will be able to do so as
            // well, however, this sample app is not designed to demonstrate the collection of such data.
            break
       case .denied, .restricted:
            // (Apple docs) "If the authorization status is restricted or denied, your app is not permitted 
            // to use location services and you should abort your attempt to use them."
            break
        case .notDetermined:
            // Request permission to access location data.
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
        }
        
        FraudForce.delegation(self)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FraudForce.start()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // The app is authorized to track the device location. FraudForce will be able to do so as
            // well, however, this sample app is not designed to demonstrate the collection of such data,
            // so we just clear our strong referene to the object.
            locationManager = nil
            break
        case .denied, .restricted:
            // Permission to track location has been denied. Neither the app nor FraudForce will be able 
            // to track the device location unless the user grants permission in Settings.
            locationManager = nil
            break
        default: break
        }
    }
}

extension AppDelegate: FraudForceDelegate {
    func shouldEnableNetworkCalls() -> Bool {
        return true
    }
}
