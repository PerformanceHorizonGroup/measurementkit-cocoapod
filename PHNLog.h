//
//  PHNLog.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 11/04/2017.
//
//

#import <Foundation/Foundation.h>

@interface PHNLog : NSObject

+ (void) log:(NSString*)format, ...;

+ (void) setDebugLogIsActive:(BOOL)isActive;

@end
