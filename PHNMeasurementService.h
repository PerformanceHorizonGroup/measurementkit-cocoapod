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
@class PHNMeasurementService;

/**
 PHNMeasurementServiceDegelate provides feedback for state changes in the mobile measurement service.
 */
@protocol PHNMeasurementServiceDegelate <NSObject>

/**
 the mobile measurement service is now fully initialised.  A install will have been recorded, if appropriate.
 */
- (void) measurementServiceDidInitialise:(PHNMeasurementService*)service;

/**
 A deep link has been recovered from the click by the mobile tracking API.  If the delegate doesn't intervene,
 it be passed to the application delegate via the version-appropriate application:openURL method.
 @return BOOL if true, deep link will be opened.
 */
- (BOOL) measurementServiceWillOpenDeepLink:(NSURL*)deepLinkUrl;
@end


/** 
 PHNMeasurementService provides an interface to PHG Mobile tracking API, and provides methods to set up the service and track events
 
 -----------------------------------------------------------------
 Please note this service is in Beta.
 -----------------------------------------------------------------
 
 Use requires the user be configured as an advertiser in Performace Horizon's affiliate tracking platform.
 */
@interface PHNMeasurementService : NSObject

/**
 additional accuracy can be gained via execution of javascript in a headless webview (Active Fingerprinting).  However, as this has performance implications (the webview must be created on the main thread), it is optional. Defaults to false.
 */
@property(nonatomic, assign) BOOL shouldActiveFingerPrint;

/**
 identifer for advertisers.  Can be used for attribution in app-app tracking scenarios.  Optional.
 @see [[[ASIdentifierManager sharedManager] advertisingIdentifier]
 */
@property(nonatomic, retain) NSUUID* idfa;


/** 
 returns singleton instance of measurement service.
 @return the shared instance of the measurement service
 */
+ (instancetype) sharedInstance;

/**
 initialises the measurement service session, generating an install event if appropriate.
 @param advertiserID The advertiser identifier provided by PHG (See Admin-Advertiser)
 @param campaignID The campaign identifier provided by PHG (See Admin-Campaign)
 */
- (void) startSessionWithAdvertiserID:(NSString*)advertiserID andCampaignID:(NSString*)campaignID;

/**
 tracks The given event
 @param Event - the event
 */
- (void) trackEvent:(PHNEvent*)event;

/**
 captures a mobile tracking id encoded in a deep link for future use by the measurement service, and returns
 the original deep-link
 @param deepLink - the deep link URL;
 @return the deep link with the mobile tracking id removed from the URL.
 */
- (NSURL*) processDeepLinkWithURL:(NSURL*)deepLink;

/**
 *  delegate to receive measurement service events.
 */
@property(nonatomic, retain) id<PHNMeasurementServiceDegelate> delegate;


@end
