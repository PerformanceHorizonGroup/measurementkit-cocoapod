//
//  PHGMobileTrackingServiceConfiguration.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 06/03/2015.
//
//

#import "PHNMeasurementServiceConfiguration.h"
#import <UIKit/UIKit.h>

@interface PHNMeasurementServiceConfiguration()

@property(nonatomic, assign) BOOL isDebug;

@end

@implementation PHNMeasurementServiceConfiguration

- (instancetype) init
{
    if (self = [super init]) {
        _isDebug = NO;
        _recordIDFA = YES;
        _debugLoggingActive = NO;
        
        //active fingerprinting defaults to on only in iOS 9.
        _activeFingerprint = NO;
    }
    
    return self;
}

+ (PHNMeasurementServiceConfiguration*) defaultConfiguration
{
    PHNMeasurementServiceConfiguration* defaultconfig = [[PHNMeasurementServiceConfiguration alloc] init];
    
    return defaultconfig;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"Configuration: {debug URLS: %d, record idfa: %d, debug logging: %d, active fingerprint: %d}",
            self.isDebug,
            self.recordIDFA,
            self.debugLoggingActive,
            self.activeFingerprint];
}

@end
