//
//  PHNAPIRequest.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 29/03/2016.
//
//

#import "PHNAPIRequest.h"
#import "PHNRequest.h"
#import "PHNRequestFactory.h"

@implementation PHNAPIRequest

- (instancetype) initWithPath:(NSString*)path andParameters:(NSDictionary*)parameters {
    
    if (self = [super init]) {
        _path = path;
        _parameters = parameters;
    }
    
    return self;
}

- (PHNRequest*) requestWithFactory:(PHNRequestFactory*)factory {
    
    PHNRequest* request = [factory mobileTrackingRequestWithPath:self.path
                                                         andParams:self.parameters];
    
    if (self.requestIdentifier) {
        request.requestIdentifier = self.requestIdentifier;
    }
    
    if (self.handler) {
        request.completionHandler = ^(PHNRequest *request, NSData *result, NSError *error) {
            self.handler(self, result, error);
        };
    }
    
    return request;
}

@end
