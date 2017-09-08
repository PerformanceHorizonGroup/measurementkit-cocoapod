//
//  PHNRequest.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 23/03/2016.
//
//

#import "PHNRequest.h"

@interface PHNRequest()

@property(nonatomic, retain) NSMutableData* receivedData;
@property(nonatomic, retain) NSURLRequest* urlRequest;

@end

@implementation PHNRequest

#pragma mark lifecycle

- (instancetype) initWithURLRequest:(NSURLRequest*)request {
    if (self = [super init]) {
        _receivedData = [NSMutableData data];
        _urlRequest = request;
    }
    
    return self;
}

- (instancetype) initWithURLRequest:(NSURLRequest*)request andCompletionHandler:(PHNRequestHandler)handler {
    
    if (self = [self initWithURLRequest:request]) {
        _completionHandler = handler;
    }
    
    return self;
}

#pragma mark NSCopying

- (instancetype) copyWithZone:(NSZone *)zone
{
    return [[PHNRequest alloc] initWithURLRequest:self.urlRequest andCompletionHandler:self.completionHandler];
}

#pragma mark NSURLSessionTaskDelegate
- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    self.completionHandler(self, error ? nil : self.receivedData, error);
}

#pragma mark NSURLSessionDataDelegate
- (void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}


@end
