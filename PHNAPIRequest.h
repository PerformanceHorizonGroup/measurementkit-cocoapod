//
//  PHNAPIRequest.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 29/03/2016.
//
//

#import <Foundation/Foundation.h>

@class PHNRequest;
@class PHNRequestFactory;
@class PHNAPIRequest;

#import "PHNAPIRequestQueue.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^PHNAPIRequestHandler)(PHNAPIRequest* apirequest, NSData* _Nullable result,NSError* _Nullable error);

@interface PHNAPIRequest : NSObject <PHNAPIRequest>

@property(nonatomic, retain, readonly) NSString* path;
@property(nonatomic, retain, readonly) NSDictionary* parameters;
@property(nonatomic, retain) NSString* _Nullable requestIdentifier;

@property(nonatomic, copy) PHNAPIRequestHandler handler;

- (instancetype) initWithPath:(NSString*)path andParameters:(NSDictionary*)parameters;
- (PHNRequest*) requestWithFactory:(PHNRequestFactory*)factory;

@end

NS_ASSUME_NONNULL_END
