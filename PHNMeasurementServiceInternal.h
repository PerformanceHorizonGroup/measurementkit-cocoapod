//
//  PHNMeasurementService.h
//  PHNMeasurementKit
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PHNMeasurementServiceStatus) {
    PHNMeasurementServiceStatusActive,
    PHNMeasurementServiceStatusQuerying,
    PHNMeasurementServiceStatusInactive,
    PHNMeasurementServiceStatusAwaitingInitialise
};

@class UIApplication;
@class PHNEvent;
@class PHNMeasurementServiceInternal;
@class PHNMeasurementServiceConfiguration;

@protocol PHNMeasurementServiceInternalDegelate <NSObject>
- (void) measurementServiceDidInitialise:(PHNMeasurementServiceInternal*)service;
- (BOOL) measurementServiceWillOpenDeepLink:(NSURL*)deepLinkUrl;
@end


@interface PHNMeasurementServiceInternal : NSObject

@property(nonatomic, retain) id<PHNMeasurementServiceInternalDegelate> delegate;

@property(nonatomic, retain) NSNumber* installed;

@property(nonatomic, readonly) NSString* advertiserID;
@property(nonatomic, readonly) NSString* campaignID;

@property(nonatomic, readonly) NSString* mobileTrackingID;

@property(nonatomic, retain) PHNMeasurementServiceConfiguration* configuration;

- (instancetype) initWithConfiguration:(PHNMeasurementServiceConfiguration*)config;

- (void) startSessionWithAdvertiserID:(NSString*)advertiserID andCampaignID:(NSString*)campaignID;
- (void) trackEvent:(PHNEvent*)event;
- (NSURL*) processDeepLinkWithURL:(NSURL*)deepLink;

@end
