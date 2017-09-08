//
//  PHNURLRequestBuilder.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 23/03/2016.
//
//

#import "PHNRequestURLBuilder.h"
#import "PHNHostHelper.h"
#import "PHNLog.h"

@interface PHNRequestURLBuilder()

@property(nonatomic, retain) PHNHostHelper* helper;

@end

@implementation PHNRequestURLBuilder

+ (PHNRequestURLBuilder*) builderWithHostHelper:(PHNHostHelper*)helper {
    return [[PHNRequestURLBuilder alloc] initWithHostHelper:helper];
}

- (instancetype) initWithHostHelper:(PHNHostHelper*)helper {
    if (self = [super init]) {
        _helper = helper;
    }
    
    return self;
}

- (NSURLRequest*) POSTWithPath:(NSString*)path andJSONBody:(NSDictionary*)body {
    
    NSURL* requesturl = [NSURL URLWithString:[[self.helper urlStringForTracking] stringByAppendingString:path]];
    
    //guard for invalid paths.
    if (!requesturl) {
        return nil;
    }
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:requesturl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError* jsonerror;
    NSData* bodydata = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonerror];
    
    if (jsonerror) {
        [PHNLog log:@"PHNMeasurementKit - request builder - invalid data in request body  %@", [jsonerror description]];
        request.HTTPBody = [NSData data];
    }
    else {
        request.HTTPBody = bodydata;
    }
    
    return request;
}

@end
