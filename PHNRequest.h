//
//  PHNRequestII.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 23/03/2016.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PHNRequest;

typedef void (^PHNRequestHandler)(PHNRequest* request, NSData* _Nullable result,NSError* _Nullable error);

@interface PHNRequest : NSObject <NSCopying, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property(nonatomic, copy) PHNRequestHandler completionHandler;
@property(nonatomic, readonly) NSURLRequest* urlRequest;
@property(nonatomic, retain) NSString* _Nullable requestIdentifier;

- (instancetype) initWithURLRequest:(NSURLRequest*)request andCompletionHandler:(PHNRequestHandler)handler;

- (instancetype) initWithURLRequest:(NSURLRequest*)request;

NS_ASSUME_NONNULL_END

@end
