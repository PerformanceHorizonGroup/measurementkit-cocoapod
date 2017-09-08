//
//  PHNEventRequest.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 29/10/2015.
//
//

#import <Foundation/Foundation.h>

#import "PHNAPIRequestQueue.h"

NS_ASSUME_NONNULL_BEGIN

@class PHNEvent;
@class PHNRequest;
@class PHNRequestFactory;

/**
 * Event Requests class - helper class for generating correctly-formatted /event requests.
 */
@interface PHNEventRequest : NSObject <PHNAPIRequest, NSCoding>

//note that this property must be set in order for a request to be generated.
@property(nonatomic) NSString* _Nullable trackingID;
@property(nonatomic, readonly) PHNEvent* event;
@property(nonatomic, readonly) NSString* campaignID;
@property(nonatomic, readonly) NSString* advertiserID;

/**
 * initialises event request with given event, campaignID, advertiserID
 * @param event - the event to be be reported to the API.
 * @param campaignID - the campaignID the event belongs to.
 * @param advertiserID - the advertiserID of the campaign owner.
 * @return initialized event
 */
- (instancetype) initWithEvent:(PHNEvent*)event
                    campaignID:(NSString*)campaignID
               andAdvertiserID:(NSString*)advertiserID;

/**
 * generates the PHNRequest for this /event request.
 * @param factory - the factory class used to instantiate the request.
 * @param host - the host component of the URL (actually, the scheme, the resource specifier, and the host)
 * @return request (as PHNRequest) prepared for sending, or nil if the request is not ready for sending. (No trackingID)
 *
 */
- (PHNRequest*) requestWithFactory:(PHNRequestFactory*)factory;

@end
    
NS_ASSUME_NONNULL_END
