//
//  AppDelegate.m
//  iovSample
//
//  Copyright (c) 2010-2019 iovation, Inc. All rights reserved.
//

#import "AppDelegate.h"
@import CoreLocation;
@import FraudForce;

@interface AppDelegate () <CLLocationManagerDelegate, FraudForceDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (CLLocationManager.locationServicesEnabled) {
        switch (CLLocationManager.authorizationStatus) {
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                // The app is authorized to track the device location. FraudForce will be able to do so as
                // well, however, this sample app is not designed to demonstrate the collection of such data.
                break;
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                // (Apple docs) "If the authorization status is restricted or denied, your app is not
                // permitted to use location services and you should abort your attempt to use them."
                break;
            case kCLAuthorizationStatusNotDetermined:
                // Request permission to access location data.
                self.locationManager = [CLLocationManager new];
                self.locationManager.delegate = self;
                [self.locationManager requestWhenInUseAuthorization];
                break;
        }
    }
    
    [FraudForce delegation:self];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FraudForce start];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // The app is authorized to track the device location. FraudForce will be able to do so as
            // well, however, this sample app is not designed to demonstrate the collection of such data,
            // so we just clear our strong referene to the object.
            self.locationManager = nil;
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            // Permission to track location has been denied. Neither the app nor FraudForce will be able
            // to track the device location unless the user grants permission in Settings.
            self.locationManager = nil;
            break;
        case kCLAuthorizationStatusNotDetermined:
            // When not determined, keep waiting (by continuing to retain the locationManager).
            break;
    }
}

#pragma mark - FraudForceDelegate protocol

- (BOOL)shouldEnableNetworkCalls {
    return YES;
}

@end
