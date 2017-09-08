//
//  PHGMobileTrackingRequestFactory.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 03/03/2015.
//
//

#import <Foundation/Foundation.h>
#import "PHNRequest.h"

@class PHNRequestURLBuilder;

@interface PHNRequestFactory : NSObject

- (PHNRequest* _Nullable) mobileTrackingRequestWithPath:(NSString* _Nonnull)path andParams:(NSDictionary* _Nullable)parameters;
- (PHNRequest* _Nullable) mobileTrackingRequestWithPath:(NSString * _Nonnull)path params:(NSDictionary * _Nullable)parameters andCompletionHandler:(PHNRequestHandler _Nullable)handler;
- (PHNRequest* _Nonnull) mobileTrackingRequestWithURLRequest:(NSURLRequest* _Nonnull)request;

- (instancetype _Nonnull) initWithURLBuilder:(PHNRequestURLBuilder* _Nonnull)builder;

@end
