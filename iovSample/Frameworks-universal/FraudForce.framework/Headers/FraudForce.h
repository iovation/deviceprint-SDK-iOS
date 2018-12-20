//
//  FraudForce.h
//  libiovation
//
//  Copyright (c) 2010-2018 iovation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol FraudForceDelegate;

/*!
 * @header
 *
 * @brief iovation FraudForce SDK for iOS
 *
 * iovation identifies devices through information collected by this SDK,
 * which runs on an end user’s iOS device. FraudForce schedules and runs
 * tasks in an asynchronous queue that collect the data necessary to generate
 * a blackbox containing details about the device. This blackbox must then be
 * transmitted to your servers to be used in a reputation check (for example a
 * @p CheckTransactionDetails call).
 *
 * @version 5.0.2
 * @copyright 2010-2018 iovation, Inc. All rights reserved.
 *
 * iovation hereby grants to Client a nonexclusive, limited, non-transferable,
 * revocable and non-sublicensable license to install, use, copy and
 * distribute the FraudForce SDK solely as necessary to use the the iovation
 * Global Device Intelligence Platform from within software created and
 * distributed by Client, pursuant to the
 * <a href="https://help.iovation.com/Downloads/iovation_SDK_License">License</a>
 * and Service Agreement between iovation and Client.
 *
 */
@interface FraudForce : NSObject

/*!
 * Starts the device inspector and returns. The inspector runs asynchronously on
 * its own thread, thereby minimizing the impact on the responsiveness of your
 * app. This method should be called in the @p -applicationDidBecomeActive:
 * method of your app delegate.
 *
 * @code
 * - (void)applicationDidBecomeActive:(UIApplication *)app
 * {
 *     [FraudForce start];
 * }
 * @endcode
 *
 * @since v4.0.0
 *
 */
+ (void)start;

/*!
 * Schedules the device inspector to start after the specified delay. The
 * inspector runs asynchronously on its own thread, thereby minimizing the
 * impact on the responsiveness of your app.This method should be called in the
 * @p -applicationDidBecomeActive: method of your app delegate.

 *
 * @code
 * - (void)applicationDidBecomeActive:(UIApplication *)app
 * {
 *     [FraudForce startAFterDelay:10.0];
 * }
 * @endcode
 *
 * @since v4.0.0
 *
 * @param delay The interval to delay before starting the inspector, in seconds.
 *
 */
+ (void)startAfterDelay:(NSTimeInterval)delay;

/*!
 * Stops the device inspector and returns. This cancels all currently-running
 * inspection jobs, if any. It may take a little time for the jobs to stop,
 * although this method returns without waiting.
 *
 * You should not normally need to call this method, as FraudForce listens
 * for @p UIApplicationDidEnterBackgroundNotification notfications in order to
 * keep itself running in the background long enough to finish its current jobs.
 * If you would rather it didn't finish its tasks in the background, you may
 * call this method in @p -applicationWillResignActive:.
 * 
 * @code
 * - (void)applicationWillResignActive:(UIApplication *)app
 * {
 *     [FraudForce stop];
 * }
 * @endcode
 *
 * @since v4.0.0
 *
 */
+ (void)stop __attribute__((deprecated("discrete control of device inspector is unnecessary, stop will be removed in a future release")));

/*!
 * Suspends the device inspector and returns. Calling this method prevents
 * FraudForce from starting any new jobs, but already executing jobs
 * continue to execute. Consider calling this method when your application
 * needs to perform an intensive operation and requires minimal resource
 * contention.
 *
 * @code
 * [FraudForce suspend];
 * expensiveOperation();
 * [FraudForce resume];
 * @endcode
 *
 * @since v4.0.0
 *
 */
+ (void)suspend __attribute__((deprecated("discrete control of device inspector is unnecessary, suspend will be removed in a future release")));

/*!
 * Resumes a suspended device inspector and returns. Call this method after
 * @p +suspend has been called, and after the completion of a resource-intensive
 * operation.
 *
 * @code
 * [FraudForce suspend];
 * expensiveOperation();
 * [FraudForce resume];
 * @endcode
 *
 * @since v4.0.0
 *
 */
+ (void)resume __attribute__((deprecated("discrete control of device inspector is unnecessary, resume will be removed in a future release")));

/*!
 * Install a delegate object that is queried to determine certain behaviors of 
 * the FraudForce SDK. Setting a delegate is optional. Sensible defaults will be 
 * used in the absence of a delegate.
 *
 * @since v5.0.0
 *
 */
#if __has_feature(nullability)
+ (void)delegation:(nullable id<FraudForceDelegate>)delegate;
#else
+ (void)delegation:(id<FraudForceDelegate>)delegate;
#endif

/*!
 * Marshalls information about the device and returns an encrypted string, or
 * blackbox, containing this information.
 *
 * @note The blackbox returned from @p bb should never be empty. An empty
 * blackbox indicates that the protection offered by the system may have been
 * compromised.
 *
 * @since v4.0.0
 *
 * @return An NSString representing a blackbox containing encrypted device information.
 *
 */
#if __has_feature(nullability)
+ (nonnull NSString *)blackbox;
#else
+ (NSString *)blackbox;
#endif

@end

/*!
 * Declares the delegate methods that the FraudForce SDK will utilize to allow for subscriber control
 * over select SDK behaviors.
 *
 * @since v5.0.0
 *
 */
@protocol FraudForceDelegate <NSObject>

/*!
 * Authorizes a network call to iovation's service that enables the collection of additional network
 * information. If this method returns NO or is not implemented then the SDK will not make network calls.
 *
 * @since v5.0.0
 *
 */
- (BOOL)shouldEnableNetworkCalls;

@end
