//
//  PHNMeasurementService.h
//  PHNMeasurementKit
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import <Foundation/Foundation.h>


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
@property(nonatomic, retain) NSUUID* idfa;
@property(nonatomic, assign) BOOL installed;

- (instancetype) initWithConfiguration:(PHNMeasurementServiceConfiguration*)config;


- (void) startSessionWithAdvertiserID:(NSString*)advertiserID andCampaignID:(NSString*)campaignID;
- (void) trackEvent:(PHNEvent*)event;
- (NSURL*) processDeepLinkWithURL:(NSURL*)deepLink;

+ (BOOL) openURL:(NSURL*)URL withCamref:(NSString*)camref;
+ (BOOL) openURL:(NSURL*)URL withAlternativeURL:(NSURL*)alternativeURL andCamref:(NSString*)camref;
/*+ (BOOL) openUniversalURL:(NSURL*)URL andCamref:(NSString*)camref;*/

@end
