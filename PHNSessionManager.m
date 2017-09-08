//
//  PHNSessionManager.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 23/03/2016.
//
//

#import "PHNSessionManager.h"
#import "PHNRequest.h"

@interface PHNSessionManager() <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property(nonatomic, retain) NSURLSession* _Nonnull session;

@property(nonatomic, retain) NSMutableDictionary<NSNumber*, PHNRequest*>* _Nonnull requests;
@property(nonatomic, retain) NSMutableDictionary<NSNumber*, NSURLSessionDataTask*>* _Nonnull tasks;

@end

@implementation PHNSessionManager

#pragma mark - lifecycle

+ (instancetype) sessionManagerWithConfiguration:(NSURLSessionConfiguration *)configuration andDelegateQueue:(NSOperationQueue*)queue
{
    return [[PHNSessionManager alloc] initWithConfiguration:configuration andDelegateQueue:queue];
}

- (instancetype) initWithConfiguration:(NSURLSessionConfiguration *)configuration andDelegateQueue:(NSOperationQueue*)queue
{
    if (self = [super init]) {
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
        _requests = [NSMutableDictionary dictionary];
        _tasks = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (instancetype) initWithConfiguration:(NSURLSessionConfiguration*)configuration
{
    return [self initWithConfiguration:configuration andDelegateQueue:nil];
}

#pragma mark - public methods

- (void) startRequest:(PHNRequest*) request {
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request.urlRequest];
    
    self.requests[@(task.taskIdentifier)] = request;
    self.tasks[@(task.taskIdentifier)] = task;
    
    [task resume];
}

#pragma mark NSURLSessionTaskDelegate
- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (!([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) ) {
        [self.requests[@(task.taskIdentifier)] URLSession:session task:task didCompleteWithError:error];
    }
    
    [self.requests removeObjectForKey:@(task.taskIdentifier)];
}

#pragma mark NSURLSessionDataDelegate
- (void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.requests[@(dataTask.taskIdentifier)] URLSession:session dataTask:dataTask didReceiveData:data];
}

- (PHNRequest* _Nullable) requestInProgressWithIdentifier:(NSString*)requestIdentifier
{
    //just loop through and return the first one that matches
    for (NSNumber* taskID in self.requests) {
        
        if ([self.requests[taskID].requestIdentifier isEqualToString:requestIdentifier]) {
            return self.requests[taskID];
        }
    }
    
    return nil;
}

- (void) cancelRequestWithIdentifier:(NSString*)requestIdentifier {
    
    for (NSNumber* taskID in self.requests) {
        
        if ([self.requests[taskID].requestIdentifier isEqualToString:requestIdentifier]) {
            [self.tasks[taskID] cancel];
        }
    }
}


@end
