//
//  PHNSessionManager.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 23/03/2016.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PHNRequest;

@protocol PHNSessionManagerSessionDelegate <NSObject>

@end

@protocol PHNSessionManagerTaskDelegate <NSObject>

@end

/**
 Router/wrapper for session objects
 */
@interface PHNSessionManager : NSObject

+ (instancetype) sessionManagerWithConfiguration:(NSURLSessionConfiguration *)configuration andDelegateQueue:(NSOperationQueue*)queue;
- (instancetype) initWithConfiguration:(NSURLSessionConfiguration*)configuration;
- (instancetype) initWithConfiguration:(NSURLSessionConfiguration *)configuration andDelegateQueue:(NSOperationQueue* _Nullable)queue;

- (void) startRequest:(PHNRequest*) request;
- (PHNRequest* _Nullable) requestInProgressWithIdentifier:(NSString*)requestIdentifier;
- (void) cancelRequestWithIdentifier:(NSString*)requestIdentifier;


@property(nonatomic, retain) id<NSURLSessionDelegate, NSURLSessionTaskDelegate> sessionDelegate;

NS_ASSUME_NONNULL_END

@end
