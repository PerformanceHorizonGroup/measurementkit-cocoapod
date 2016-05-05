//
//  PHGMobileTrackingServiceConfiguration.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 06/03/2015.
//
//

#import <Foundation/Foundation.h>

/**
 PHNMeasurementServiceConfiguration provides configuration options for setting up instances of PHNMeasurementService
 */
@interface PHNMeasurementServiceConfiguration : NSObject

/**
 automatically collect the IDFA, if Adservices.framework is available.  Defaults to YES;
 */
@property(nonatomic, assign) BOOL recordIDFA;

/**
 additional accuracy can be gained via execution of javascript in a headless webview/safariviewcontroller (Active Fingerprinting).
 In iOS 8, defaults to NO.  iOS 9>, defaults to YES.
 
 ------------------------------------------------
 Please note that these defaults have performance implications.  The webview is created on the main thread.
 ------------------------------------------------
 */
@property(nonatomic, assign) BOOL activeFingerprint;

/**
 *
 */
@property(nonatomic, assign) BOOL serviceMode;

+ (PHNMeasurementServiceConfiguration*) defaultConfiguration;

@end
