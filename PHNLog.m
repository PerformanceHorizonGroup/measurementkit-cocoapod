//
//  PHNLog.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 11/04/2017.
//
//

#import "PHNLog.h"

@implementation PHNLog

#ifdef DEBUG
static BOOL kPHNLogEnabled = YES;
#else
static BOOL kPHNLogEnabled = NO;
#endif

+ (void) log:(NSString*)format, ... {
    
    if (kPHNLogEnabled) {
        va_list args;
        va_start(args, format);
        
        NSString* extendedformat = [@"PHNMeasurementKit - " stringByAppendingString:format];

        NSLogv(extendedformat, args);
        va_end(args);
    }
}

+ (void) setDebugLogIsActive:(BOOL)isActive {
    kPHNLogEnabled = isActive;
}

@end
