//
//  AppDelegate.swift
//  iovSampleSwiftUI
//
// Copyright © 2024 TransUnion Inc. All rights reserved.
//

import Foundation
import CoreLocation
import FraudForce
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
                
        // Override point for customization after application launch.
        locationManager = CLLocationManager()
        var authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager!.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        switch authorizationStatus {
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
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
        
        FraudForce.delegation(self)
        
        return true
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
