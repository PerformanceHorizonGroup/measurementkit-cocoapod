//
//  PHNAPIRequestQueue.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 30/10/2015.
//
//

#import <Foundation/Foundation.h>

#import "PHNSimpleStore.h"

NS_ASSUME_NONNULL_BEGIN

@class PHNEventRequest;
@class PHNRequestFactory;
@class PHNRequestQueue;
@class PHNRequest;

@protocol PHNAPIRequest <NSObject>

- (PHNRequest*) requestWithFactory:(PHNRequestFactory*)factory;
@end

@interface PHNAPIRequestQueue : NSObject <PHNSimplyStoreable>

- (instancetype) initWithRequestQueue:(PHNRequestQueue*)requestQueue
                              andFactory:(PHNRequestFactory*)factory;

+ (instancetype) APIQueueWithRequestQueue:(PHNRequestQueue*)requestQueue
                               andFactory:(PHNRequestFactory*)factory;

/**
 * Adds api request to queue. 
 * 
 * If request is ready (it can produce transport form), and queue is ready
 * (not paused). It will be immediately passed to the transport queue.  If not, it is stored for later sending.
 * @param
 */
- (void) addRequest:(PHNEventRequest*)request;


- (BOOL) executeRequest:(id<PHNAPIRequest>)request;
- (BOOL) requestInProgessWithIdentifier:(NSString*)identifier;
- (void) cancelRequestWithIdentifier:(NSString*)requestIdentifier;

/**
 * clears all incomplete requests from the queue.
 */
- (void) clearQueue;

- (void) setTransportQueuePaused:(Boolean)isPaused;

@property(nonatomic) NSString* _Nullable trackingID;

@property(nonatomic, readonly) NSInteger incompleteRequests;
@property(nonatomic, readonly) NSInteger requestsInProgess;

///Transport queue for the request sending.
@property(nonatomic, readonly) PHNRequestQueue* transportQueue;

/// isQueuePaused - if paused, the queue won't allow requests to move to the transport queue.
@property(nonatomic) BOOL isQueuePaused;


@end


NS_ASSUME_NONNULL_END