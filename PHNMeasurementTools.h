//
//  PHGTools.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PHNDeviceFamily) {
    PHNDeviceFamilyiPhone,
    PHNDeviceFamilyiPod,
    PHNDeviceFamilyiPad,
    PHNDeviceFamilyAppleTV,
    PHNDeviceFamilyUnknown,
};

@interface PHNMeasurementTools : NSObject

+ (NSString *)modelName;

@end

extern NSString * PHNQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding);
