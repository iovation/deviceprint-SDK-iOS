//
//  AppDelegate.m
//  iovSample
//
//  Created by Greg Crow on 9/11/13.
//  Copyright (c) 2013 iovation, Inc. All rights reserved.
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

    // Pattern for requesting locaion tracking permission on iOS 8 and earlier.
    // See http://nshipster.com/core-location-in-ios-8/ for details.
    if (CLLocationManager.locationServicesEnabled) {
        if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
            self.locationManager = [CLLocationManager new];
            self.locationManager.delegate = self;
            if ([CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)]) {
                // Request permission to access location data.
                [self.locationManager requestWhenInUseAuthorization];
            } else {
                // Start monitoring location to implicitly request permission.
                [self.locationManager startUpdatingLocation];
            }
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

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // Keep waiting if not determined.
    if (status == kCLAuthorizationStatusNotDetermined) return;
    if (
           status == kCLAuthorizationStatusAuthorized
        || status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse
    ) {
        // The app is authorized to track the device location. FraudForce
        // will be able to do so as well. This sample app does not collect
        // lcoation itself, so we just free the object.
        self.locationManager = nil;
    } else {
        // Permission to track location has been denied. Neither the app nor
        // FraudForce will be able to track the device location unless the
        // user grants permission in Settings. On iOS 8, you can send them
        // right to settings at a later date.
        // See http://nshipster.com/core-location-in-ios-8/ for examples.
        self.locationManager = nil;
    }
}

#pragma mark - FraudForceDelegate protocol

- (BOOL)shouldEnableNetworkCalls {
    return YES;
}

@end
