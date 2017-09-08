//
//  PHNAPIRequestQueue.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 30/10/2015.
//
//

#import "PHNAPIRequestQueue.h"
#import "PHNRequestQueue.h"
#import "PHNEventRequest.h"

@interface PHNAPIRequestQueue()

- (instancetype) initWithRequestQueue:(PHNRequestQueue*)requestQueue
                              factory:(PHNRequestFactory*)factory
            andIncompleteRequestQueue:(NSMutableArray*)incompleteRequests;


//factory for generating PHNRequests.
@property(nonatomic, readonly) PHNRequestFactory* factory;

//queue for incomplete requests.
@property(nonatomic, readonly) NSMutableArray<PHNEventRequest*> * incompleteQueue;

@end


@implementation PHNAPIRequestQueue

#pragma mark lifecycle

- (instancetype) initWithRequestQueue:(PHNRequestQueue*)requestQueue
                              factory:(PHNRequestFactory*)factory
            andIncompleteRequestQueue:(NSMutableArray*)incompleteRequests
{
    if (self = [super init]) {
        _transportQueue = requestQueue;
        _factory = factory;
        _incompleteQueue = incompleteRequests;
        _isQueuePaused = NO;
    }
    
    return self;
}

+ (instancetype) APIQueueWithRequestQueue:(PHNRequestQueue*)requestQueue
                               andFactory:(PHNRequestFactory*)factory
{
    return [[PHNAPIRequestQueue alloc] initWithRequestQueue:requestQueue andFactory:factory];
}

- (instancetype) initWithRequestQueue:(PHNRequestQueue*)requestQueue
                              andFactory:(PHNRequestFactory*)factory
{
    self = [self initWithRequestQueue:requestQueue
                                  factory:factory
            andIncompleteRequestQueue:[NSMutableArray array]];
    
    return self;
}

#pragma mark public

- (void) addRequest:(PHNEventRequest*)request atFront:(BOOL)shouldbefirst
{
    //if a trackingID is set, copy it into the request.
    if (self.trackingID) {
        request.trackingID = self.trackingID;
    }
    
    //queue up the request
    [self queueRequest:request atFront:shouldbefirst];
}

- (void) addRequest:(PHNEventRequest*)request;
{
    [self addRequest:request atFront:NO];
}

- (BOOL) executeRequest:(id<PHNAPIRequest>)request
{
    PHNRequest* transportrequest = [request requestWithFactory:self.factory];
    
    if (transportrequest) {
        [self.transportQueue executeRequest:transportrequest];
    }
    
    return transportrequest != nil;
}

- (BOOL) requestInProgessWithIdentifier:(NSString*)identifier {
    return [self.transportQueue requestInProgessWithIdentifier:identifier];
}

- (void) cancelRequestWithIdentifier:(NSString*)requestIdentifier {
    [self.transportQueue cancelRequestWithIdentifier:requestIdentifier];
}


- (void) setTrackingID:(NSString *)trackingID
{
    _trackingID = trackingID;
    
    if ( trackingID) {
    
        for (PHNEventRequest* incomplete in [self.incompleteQueue copy]) {
            
            if (!incomplete.trackingID) {
                incomplete.trackingID = trackingID;
            }
            
            //remove from incomplete queue.
            [self.incompleteQueue removeObject:incomplete];
            
            //try and resend.
            [self queueRequest:incomplete atFront:NO];
        }
    }
}

- (void) setIsQueuePaused:(BOOL)isQueuePaused {
    
    _isQueuePaused = isQueuePaused;
    
    if (!isQueuePaused) {
        
        //try and resend requests.
        for (PHNEventRequest* incomplete in [self.incompleteQueue copy]) {
            
            //remove from incomplete queue.
            [self.incompleteQueue removeObject:incomplete];
            
            //try and resend.
            [self queueRequest:incomplete atFront:NO];
        }
    }
}

- (NSInteger) incompleteRequests
{
    return self.incompleteQueue.count;
}

- (NSInteger) requestsInProgess
{
    return self.transportQueue.count;
}

- (void) clearQueue
{
    [self.incompleteQueue removeAllObjects];
}

- (void) setTransportQueuePaused:(Boolean)isPaused {
    self.transportQueue.isPaused = isPaused;
}

#pragma mark private

- (void) queueRequest:(PHNEventRequest*)request atFront:(BOOL)shouldbefirst
{
    
    //generate the transport representation
    PHNRequest* transportRequest= [request requestWithFactory:self.factory];
    
    //if it's good, send it off/
    if (transportRequest && ! self.isQueuePaused) {
        [self.transportQueue addRequest:transportRequest];
    }
    else {
        if (shouldbefirst) {
            [self.incompleteQueue insertObject:request atIndex:0];
        }
        else {
            [self.incompleteQueue addObject:request];
        }
    }
}

#pragma mark - PHNSimplyStorable

- (NSDictionary*) storageForm
{
    NSMutableArray<NSData*>* eventqueue = [NSMutableArray array];
    
    //convert each request into it's stored form.
    for (id<PHNAPIRequest> request in self.incompleteQueue) {
        [eventqueue addObject:[NSKeyedArchiver archivedDataWithRootObject:request]];
    }
    
    return @{@"event_queue":eventqueue};
}

- (void) updateWithStorageForm:(NSDictionary *)storageForm
{
    if (! storageForm[@"event_queue"])
        return;
    
    //NSMutableArray<NSData*>* archivedeventqueue = [NSMutableArray array];
    
    for (NSData* archivedevent in storageForm[@"event_queue"]) {
        
        [self addRequest:[NSKeyedUnarchiver unarchiveObjectWithData:archivedevent] atFront:YES];
    }
}


@end
