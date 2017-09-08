//
//  PHGMobileTrackingRequestQueue.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 26/02/2015.
//
//

#import <Foundation/Foundation.h>

@class PHNRequest;
@class PHNSessionManager;
@class PHNRequestFactory;
@class PHNExecutor;

NS_ASSUME_NONNULL_BEGIN

@interface PHNRequestQueue : NSObject

@property(nonatomic, readonly) NSInteger count;
@property(nonatomic, readonly) BOOL requestInProgress;
@property(nonatomic) BOOL isPaused;

/**
 Delay between request batch sends in the queue.  Defaults to 60 seconds.
 */
@property(nonatomic) double requestBatchDelay;

/**
 Size of request batches in the queue.  Defaults to 5.
 */
@property(nonatomic) NSInteger requestBatchSize;


//adds request to queue.
- (void) addRequest:(PHNRequest*)request;

//just intiates the request, no adding to queue.
- (void) executeRequest:(PHNRequest*)request;
- (BOOL) requestInProgessWithIdentifier:(NSString*)identifier;
- (void) cancelRequestWithIdentifier:(NSString*)requestIdentifier;

- (instancetype _Nonnull) initWithSession:(PHNSessionManager*)sessionManager
                                  factory:(PHNRequestFactory*)factory
                              andExecutor:(PHNExecutor* _Nullable)executor;

+ (instancetype _Nonnull) requestQueueWithSession:(PHNSessionManager*) sessionManager
                                          factory:(PHNRequestFactory*)factory
                                      andExecutor:(PHNExecutor* _Nullable)executor;


NS_ASSUME_NONNULL_END

@end
