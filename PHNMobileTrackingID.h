//
//  PHGMobileTrackingID.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 11/03/2015.
//
//

#import <Foundation/Foundation.h>

@interface PHNMobileTrackingID : NSObject

+ (void) deleteID;
+ (NSString*) getID;
+ (void) storeID:(NSString*)string;

@end
