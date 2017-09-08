//
//  PHGMeasurementServiceInternal+PHG.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 30/10/2015.
//
//

#import "PHNMeasurementServiceInternal.h"

@interface PHNMeasurementServiceInternal (PHG)

- (void) clearMeasurementServiceIDs;
+ (void) clearMeasurementServiceIDs;

@property(nonatomic, retain) NSString* mobileTrackingID;
@property(nonatomic, assign) BOOL trackingIsActive;

@end