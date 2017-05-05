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
 
 Due to updates to the app developer programme license agreement, active fingerprinting is now disabled by default
 */
@property(nonatomic, assign) BOOL activeFingerprint;

/**
 debug logging can be used to identify any issues in the configuration of MeasurementKit.
 
 
 */
@property(nonatomic, assign) BOOL debugLoggingActive;

 

+ (PHNMeasurementServiceConfiguration*) defaultConfiguration;

@end
