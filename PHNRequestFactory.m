//
//  PHGMobileTrackingRequestFactory.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 03/03/2015.
//
//

#import "PHNRequestFactory.h"
#import "PHNRequestURLBuilder.h"

@interface PHNRequestFactory()

@property(nonatomic, retain) PHNRequestURLBuilder* builder;

@end

@implementation PHNRequestFactory

- (instancetype) initWithURLBuilder:(PHNRequestURLBuilder*)builder {
    if (self = [super init]) {
        _builder = builder;
    }
    
    return self;
}

- (PHNRequest* _Nullable) mobileTrackingRequestWithPath:(NSString *)path andParams:(NSDictionary *)parameters {
   
    NSURLRequest* request = [self.builder POSTWithPath:path andJSONBody:parameters];
    
    if (!request) {
        return nil;
    }
    else {
        return [[PHNRequest alloc] initWithURLRequest:request];
    }
}

- (PHNRequest*) mobileTrackingRequestWithPath:(NSString *)path params:(NSDictionary *)parameters andCompletionHandler:(PHNRequestHandler)handler{
    
    NSURLRequest* request = [self.builder POSTWithPath:path andJSONBody:parameters];
    
    if (!request) {
        return nil;
    }
    else {
        return [[PHNRequest alloc] initWithURLRequest:request andCompletionHandler:handler];
    }
}

- (PHNRequest*) mobileTrackingRequestWithURLRequest:(NSURLRequest* _Nonnull)request
{
    return [[PHNRequest alloc] initWithURLRequest:request];
}

@end
