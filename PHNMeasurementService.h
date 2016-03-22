//
//  PHNMeasurementService.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 29/10/2015.
//
//

#import <Foundation/Foundation.h>

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
@class PHNMeasurementServiceConfiguration;

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
- (BOOL) measurementService:(PHNMeasurementService*)service willOpenDeepLink:(NSURL*)deepLinkUrl;
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
 identifer for advertisers.  Can be used for attribution in app-app tracking scenarios.  Optional.
 @see [[[ASIdentifierManager sharedManager] advertisingIdentifier]
 */
@property(nonatomic, retain) NSUUID* idfa;


/**
 returns singleton instance of measurement service.
 @return the shared instance of the measurement service
 */
+ (instancetype) sharedInstance;

+ (void) setSharedInstance:(PHNMeasurementService*)sharedInstance;

/**
 initialises measurement service with given configuration
 @param config the measurement service configuration options
 @return initialised measurement service, configured as requested
 
 @see PHNMeasurementServiceConfiguration
 */
- (instancetype) initWithConfiguration:(PHNMeasurementServiceConfiguration*)config;

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
 captures a mobile tracking id or camref encoded in a deep link for future use by the measurement service, and returns
 the original deep-link
 @param deepLink - the deep link URL;
 @return the deep link with the mobile tracking id or camref removed from the URL.
 */
- (NSURL*) processDeepLinkWithURL:(NSURL*)deepLink;

/**
 *  delegate to receive measurement service events.
 */
@property(nonatomic, retain) id<PHNMeasurementServiceDegelate> delegate;

/**
 appends the given camref onto the url, then opens the url.
 @param url - given url to open
 @param camref - the campaign reference that encodes the publisher/campaign combination.
 @return false if the given URL can not be opened.
 @see UIApplication - openURL:
 @warning - Please note that the method does not check whether the given URL can be opened.
 */
+ (BOOL) openURL:(NSURL*)URL withCamref:(NSString*)camref;

/**
 attempts to open the given url, if, attempts to open the provided alternative.
 @param url - given url to open
 @param alternativeURL - alternative url
 @param camref - the campaign reference that encodes the publisher/campaign combination.
 @return false if the given URL can not be opened.
 @see UIApplication - openURL:
 @see UIApplication - canOpenURL:
 */
+ (BOOL) openURL:(NSURL*)URL withAlternativeURL:(NSURL*)alternativeURL andCamref:(NSString*)camref;


/**
 opens the given url, with universal behaviour.  Please note that universal links must be configured with
 the measurementKit API, and in your application.  (See Universal link guide)

+ (BOOL) openUniversalURL:(NSURL*)URL withAlternativeURL:(NSURL*)alternativeURL andCamref:(NSString*)camref;*/

/**
 measurement kit will estimate installs when it allocates a mobile tracking ID.  If the application has been internally tracking versions, however, this may be more accurate than the estimate.  The following property can be used to override the estimate and generate an install conversion on registration.
 */
@property(nonatomic, assign) BOOL installed;

@end

