//
//  PHGMobileTracking.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import <Foundation/Foundation.h>
@class UIApplication;
@class PHGMobileTrackingEvent;
@class PHGMobileTrackingService;

/**
 PHGMobileTrackingServiceDegelate provides feedback for state changes in the mobile tracking service.
 */
@protocol PHGMobileTrackingServiceDegelate <NSObject>

/**
 the mobile tracking service is now fully initialised.  A install will have been recorded, if appropriate.
 */
- (void) PHGMobileTrackingServiceDidInitialise:(PHGMobileTrackingService*)service;

/**
 A deep link has been recovered from the click by the mobile tracking service.  If the delegate doesn't intervene,
 it be passed to the application delegate via - application:openURL:sourceApplication:annotation:
 @return BOOL - if true, deep link will be opened.
 */
- (BOOL) PHGMobileTrackingServiceWillOpenDeepLink:(NSURL*)deepLinkUrl;
@end


/** 
 PHGMobileTrackingService provides an interface to PHG Mobile Tracking service, and provides methods to set up the service and track events
 */
@interface PHGMobileTrackingService : NSObject

/**
 additional tracking information can be gained via execution of javascript in a headless webview (Active Fingerprinting).  However, as this has performance implications (the webview must be created on the main thread), it is optional.  Please note, however, the accuracy of matches will be reduced if active fingerprints are disabled.  Defaults to false.
 */
@property(nonatomic, assign) BOOL shouldActiveFingerPrint;

/**
 identifer for advertisers.  Can be used for attribution in app-app tracking scenarios.  Optional.
 @see [[[ASIdentifierManager sharedManager] advertisingIdentifier]
 */
@property(nonatomic, retain) NSUUID* idfa;


/** 
 returns singleton instance of tracking service.
 */
+ (instancetype) trackingInstance;

/**
 initialises the tracking service, generating an install event if appropriate.
 @param advertiserID The advertiser identifier provided by PHG (See Admin-Advertiser)
 @param campaignID The campaign identifier provided by PHG (See Admin-Campaign)
 */
- (void) startTrackingWithAdvertiserID:(NSString*)advertiserID andCampaignID:(NSString*)campaignID;

/**
 sets a global tracking property.
 @param key Key for the property.
 @param value The property object.
 */
- (void) setTrackingPropertyWithKey:(NSString*)key andValue:(NSObject*)value;

/**
 tracks The given event
 @param Event - the event
 */
- (void) trackEvent:(PHGMobileTrackingEvent*)event;

/**
 captures a mobile tracking id encoded in a deep link for future use by mobile tracking, and returns
 the original deep-link
 @param deepLink - the deep link URL;
 @return the deep link with the mobile tracking id removed from the URL.
 */
- (NSURL*) processDeepLinkWithURL:(NSURL*)deepLink;

@property(nonatomic, retain) id<PHGMobileTrackingServiceDegelate> delegate;


@end
