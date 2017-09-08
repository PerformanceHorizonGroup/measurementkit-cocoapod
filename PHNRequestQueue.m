//
//  PHGMobileTrackingRequestQueue.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 26/02/2015.
//
//

#import <UIKit/UIKit.h>
#import "PHNRequestQueue.h"

#import "PHNRequest.h"
#import "PHNExecutor.h"
#import "PHNRequestFactory.h"
#import "PHNSessionManager.h"

#import <Availability.h>
#import "PHNLog.h"

@interface PHNRequestQueue()

@property(nonatomic, retain) PHNExecutor* executor;
@property(nonatomic, retain) PHNRequestFactory* factory;
@property(nonatomic, retain) PHNSessionManager* sessionManager;


@property(nonatomic, retain) NSMutableArray<PHNRequest*>* _Nonnull requestQueue;
@property(nonatomic, assign) BOOL requestInProgress;
@property(nonatomic, assign) NSInteger failCount;
@property(nonatomic, copy) PHNRequestHandler uploadHandler;
@property(nonatomic) NSInteger batchCount;

- (void) writeToDisk;
- (void) loadFromDisk;
- (void) uploadRequest;

@end

@implementation PHNRequestQueue

#pragma mark - lifecycle

- (instancetype) initWithSession:(PHNSessionManager* _Nonnull)sessionManager
                      factory:(PHNRequestFactory* _Nonnull)factory
                       andExecutor:(PHNExecutor* _Nullable)executor
{
    if (self = [super init]) {
        _sessionManager = sessionManager;
        _factory = factory;
        
        if (executor.maxConcurrentOperationCount != 1) { //needs to be a serial opqueue.
            NSOperationQueue* queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = 1;
            
            if ([queue respondsToSelector:@selector(setQualityOfService:)]) {
                queue.qualityOfService = NSQualityOfServiceUtility;
            }
            
            _executor = [[PHNExecutor alloc] initWithOperationQueue:queue];
        }
        else {
            _executor = executor;
        }
        //set up internal variables
        _requestQueue = [[NSMutableArray alloc] init];
        _failCount  = 0;
        _isPaused= NO;
        _requestInProgress = NO;
        _requestBatchDelay = 5*60;
        _requestBatchSize = 5;
        _batchCount = 0;
        
        
        //set up notification.
        PHNRequestQueue* __weak weakself = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:self.executor.operationQueue usingBlock:^(NSNotification *note) {
            [weakself writeToDisk];
        }];
        
        //block for completing uploads.
        _uploadHandler = ^(PHNRequest *request, NSData *result, NSError *error) {
            
            @try {
                [weakself uploadCompleteWithRequest:request result:result andError:error];
            }
            @catch (NSException* exception){
                [PHNLog log:@"PHNRequestQueue - caught unexpected exception: %@", [exception description]];
            }
        };
        
        //queue up operations.  Op 2 is dependent on 1 completing, with delay.
        [self.executor execute:^{
            [weakself loadFromDisk];
            
            [weakself.executor execute:^{
                [weakself uploadRequest];
            } withDelay:1.0];
        }];
    }
    
    return self;
        
}

+ (instancetype) requestQueueWithSession:(PHNSessionManager* _Nonnull)sessionManager
                                 factory:(PHNRequestFactory* _Nonnull)factory
                             andExecutor:(PHNExecutor* _Nullable)executor
{
    return [[PHNRequestQueue alloc] initWithSession:sessionManager
                                            factory:factory
                                        andExecutor:executor];
}

#pragma mark - public methods

- (NSInteger) count {
    return self.requestQueue.count;
}

- (void) addRequest:(PHNRequest*)request
{
    if (self.requestQueue.count > 999 || !request) { //simple max of 1000 requests allowed.
        return;
    }

    [self.requestQueue addObject:[request copy]];
    [self uploadRequest];
}

- (void) executeRequest:(PHNRequest*)request
{
    [self.sessionManager startRequest:request];
}

- (BOOL) requestInProgessWithIdentifier:(NSString*)identifier
{
    return ([self.sessionManager requestInProgressWithIdentifier:identifier] != nil);
}

- (void) cancelRequestWithIdentifier:(NSString*)requestIdentifier {
    [self.sessionManager cancelRequestWithIdentifier:requestIdentifier];
}

#pragma mark - private methods

- (void) uploadRequest
{
    if (self.requestQueue.count > 0 && !self.isPaused && !self.requestInProgress) {
        
        self.requestInProgress = YES;
        self.requestQueue.firstObject.completionHandler = self.uploadHandler;
        
        [self.sessionManager startRequest:self.requestQueue.firstObject];
    }
}

- (void) uploadCompleteWithRequest:(PHNRequest*)request result:(NSData*)result andError:(NSError*)error
{
    self.requestInProgress = NO;
    
    if (!error) {
        [self.requestQueue removeObject:request];
    }
    else
    {
        self.failCount = self.failCount + 1;
        
        if (self.failCount > 3) {
            self.queueIsPaused = YES;
            self.failCount = 0;
        }
        
        [PHNLog log:@"error uploading from request queue."];
    }
    
    if (self.requestQueue.count > 0) {
        PHNRequestQueue* __weak weakself = self;
        
        self.batchCount = (self.batchCount + 1) % self.requestBatchSize;
        
        //send in batches of 5 (which is pretty unlikely in itself, but still...)
        double delay = (!self.batchCount) ? self.requestBatchDelay : 0.0;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((delay) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself uploadRequest];
        });
    }
}

- (void) writeToDisk{
    
    NSMutableArray* requestsarray = [NSMutableArray array];

    //don't want anyone going near the request queue at present.
    for (PHNRequest* request in self.requestQueue) {
        [requestsarray addObject:request.urlRequest];
    }
    
    [self.requestQueue removeAllObjects];

    if (requestsarray.count > 0) {
    
        NSData* requestlist = [NSKeyedArchiver archivedDataWithRootObject:requestsarray];
        
        NSFileManager* sharedfilemanager = [NSFileManager defaultManager];
        
        NSError* error;
        
        NSURL* cachedirectory= [sharedfilemanager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
        
        NSURL* phgdirectory = [cachedirectory URLByAppendingPathComponent:@"com.performancehorizon.phnmt/"];
        NSURL* phgfileurl = [phgdirectory URLByAppendingPathComponent:@"eventcache.cache"];
        
        if (!([sharedfilemanager fileExistsAtPath:phgdirectory.path])) {
            [sharedfilemanager createDirectoryAtURL:phgdirectory withIntermediateDirectories:NO attributes:nil error:nil];
        }

        [requestlist writeToFile:phgfileurl.path options:NSDataWritingFileProtectionComplete error:&error];
        
        if (!error) {
            [PHNLog log:@"request cache written to disk"];
        }
        else {
            [PHNLog log:@"cache write error."];
        }
    }
}

- (void) loadFromDisk {
    
    [PHNLog log:@"Loading from disk."];
    
    NSFileManager* sharedfilemanager = [NSFileManager defaultManager];

    NSURL* cachedirectory= [sharedfilemanager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];

    NSURL* url = [cachedirectory URLByAppendingPathComponent:@"com.performancehorizon.phnmt/eventcache.cache"];
    
    NSData* archive;
    if ((archive = [sharedfilemanager contentsAtPath:url.path])) {
        NSArray* requests = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
        
        for (NSURLRequest* urlrequest in requests) {
            
            [self.requestQueue addObject:[self.factory mobileTrackingRequestWithURLRequest:urlrequest]];
        }
    
        [sharedfilemanager removeItemAtURL:url error:nil];
    }
}

+ (void) clearCache {
    
    NSFileManager* sharedfilemanager = [NSFileManager defaultManager];
    
    NSURL* cachedirectory= [sharedfilemanager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL* url = [cachedirectory URLByAppendingPathComponent:@"com.performancehorizon.phnmt/eventcache.cache"];
    
    [sharedfilemanager removeItemAtURL:url error:nil];
}


- (void) setQueueIsPaused:(BOOL)isPaused
{
    _isPaused = isPaused;
    
    if (!isPaused) {
        [self uploadRequest];
    }
}


@end
