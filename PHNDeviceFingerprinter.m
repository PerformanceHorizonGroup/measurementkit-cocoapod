//
//  PHGMobileTrackingDeviceFingerPrinter.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 03/03/2015.
//
//

#import "PHNDeviceFingerprinter.h"
#import "PHNMeasurementTools.h"
#import <UIKit/UIKit.h>

@implementation PHNDeviceFingerprinter

- (NSDictionary*) fingerprint
{
    NSMutableDictionary* trackingProperties = [NSMutableDictionary dictionary];
    
    trackingProperties[@"ios_modelname"] = [PHNMeasurementTools modelName];
    trackingProperties[@"osversion"] = [UIDevice currentDevice].systemVersion;
    trackingProperties[@"ios_idfv"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    trackingProperties[@"ios_locales"] = [[NSBundle mainBundle] preferredLocalizations];
    //trackingProperties[@"trackingsdkbuild"] = PHGTrackingSDKBuild;
    
    if ([[NSBundle mainBundle] bundleIdentifier]) {
        trackingProperties[@"ios_bundleid"] = [[NSBundle mainBundle] bundleIdentifier];
    }
    
    return trackingProperties;
}

@end
