//
//  PHGMobileTracking.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import "PHNMeasurementServiceInternal.h"

#import "PHNEvent.h"
#import "PHNEvent+Internals.h"

#import "PHNRequestQueue.h"
#import "PHNRequestFactory.h"

#import "PHNEventRequest.h"

#import "PHNMeasurementServiceConfiguration.h"

#import "PHNMobileTrackingID.h"
#import "PHNDeepLinkProcessor.h"

#import "PHNClickURLBuilder.h"
#import "PHNExecutor.h"

#import "PHNSessionManager.h"
#import "PHNMeasurementSessionManager.h"
#import "PHNActiveFingerprinter.h"

#import "PHNAPIRequest.h"
#import "PHNRequestFactory.h"
#import "PHNRequestURLBuilder.h"
#import "PHNRegistrationManager.h"
#import "PHNHostHelper.h"

#import <Bolts/Bolts.h>

#import <Reachability/Reachability.h>
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>

#import "PHNLog.h"

static NSString* kPHGTrackingServiceActiveKey = @"com.performancehorizon.mmk.isactive"; //user defaults - active.
static NSString* kPHGTrackingServiceCamRef = @"com.performancehorizon.mmk.camref";

#define PHGTrackingSDKBuild @"2";

@interface PHNMeasurementServiceConfiguration(debug)
@property(nonatomic, assign) BOOL isDebug;
@end

@interface PHNMeasurementServiceInternal() <PHNRegistrationManagerDelegate>

//redefine internals
@property(nonatomic, retain) NSString* advertiserID;
@property(nonatomic, retain) NSString* campaignID;
@property(nonatomic, retain) NSString* mobileTrackingID;

@property(nonatomic, retain) NSString* camref;
@property(nonatomic, retain) NSNumber* trackingActive;

//dependencies
@property(nonatomic, retain) NSOperationQueue* trackingSessionQueue;
@property(nonatomic, retain) PHNAPIRequestQueue* requestQueue;
@property(nonatomic, retain) Reachability* reachabilityMonitor;
@property(nonatomic, retain) PHNRegistrationManager* registrationManager;

//state management
@property(nonatomic, assign) PHNMeasurementServiceStatus status;

@property(nonatomic, retain) NSUUID* localID;

- (void) setTrackingID:(NSString*)trackingID;
- (void) triggerRecoveredDeepLink:(NSURL*)deepLink;
@end

@implementation PHNMeasurementServiceInternal

#pragma mark lifecycle

- (instancetype) initWithConfiguration:(PHNMeasurementServiceConfiguration*)config
{
    [PHNLog setDebugLogIsActive:config.debugLoggingActive];
    
    NSOperationQueue* trackingsessionqueue = [[NSOperationQueue alloc] init];
    
    if ([trackingsessionqueue respondsToSelector:@selector(setQualityOfService:)]) {
        trackingsessionqueue.qualityOfService = NSQualityOfServiceUtility;
    }
    
    trackingsessionqueue.maxConcurrentOperationCount = 1; //go away, threading problems.
    trackingsessionqueue.name = @"phg.mobiletrackingqueue";
    
    PHNHostHelper* hosthelper = [[PHNHostHelper alloc] init];
    hosthelper.isDebug = config.isDebug;
    
    NSURLSessionConfiguration* sessionconfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionconfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    PHNRequestFactory* factory = [[PHNRequestFactory alloc] initWithURLBuilder:
                                  [[PHNRequestURLBuilder alloc] initWithHostHelper:hosthelper]];
    
    PHNSessionManager* sessionmanager = [PHNMeasurementSessionManager sessionManagerWithConfiguration:sessionconfiguration
                                                                                     andDelegateQueue:trackingsessionqueue];
    
    PHNRequestQueue* requestqueue = [PHNRequestQueue requestQueueWithSession:sessionmanager
                                                                     factory:factory
                                                                 andExecutor:[PHNExecutor executorWithOperationQueue:trackingsessionqueue]];
    
    PHNAPIRequestQueue* apiqueue = [[PHNAPIRequestQueue alloc] initWithRequestQueue:requestqueue
                                                                         andFactory:factory];
    
    PHNActiveFingerprinter* active = [[PHNActiveFingerprinter alloc] initWithHostHelper:hosthelper];
    
    self = [self initWithConfiguration:config
                   registrationManager:[[PHNRegistrationManager alloc] initWithRequestQueue:apiqueue andActiveFingerprinter:active]
                          reachability:[Reachability reachabilityWithHostName:@"www.google.com"]
                        operationQueue:trackingsessionqueue
                    andAPIRequestQueue:apiqueue];
    
    return  self;
}

- (instancetype) initWithConfiguration:(PHNMeasurementServiceConfiguration*)config
                   registrationManager:(PHNRegistrationManager*)registrationManager
                          reachability:(Reachability*)reachability
                        operationQueue:(NSOperationQueue*)queue
                    andAPIRequestQueue:(PHNAPIRequestQueue*)requestQueue
{
    if (self = [super init])
    {
        _configuration = config;
        _trackingSessionQueue = queue;
        
        _requestQueue = requestQueue;
        [_requestQueue setTransportQueuePaused:NO];
        
        _registrationManager = registrationManager;
        _registrationManager.delegate = self;
        
        [PHNLog log: @"Init MeasurementService with configuration: %@", [self.configuration description]];
        
        //ensures that the activity state is written to disk.
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        
        _camref = [[NSUserDefaults standardUserDefaults] stringForKey:kPHGTrackingServiceCamRef];
        _trackingActive = [[NSUserDefaults standardUserDefaults] objectForKey:kPHGTrackingServiceActiveKey];
        
        _reachabilityMonitor = reachability;
        [_reachabilityMonitor startNotifier];
        
        __weak typeof(self) weakself = self;
        [_reachabilityMonitor setReachableBlock:^(Reachability* reachability) {
            
            if (weakself.status == PHNMeasurementServiceStatusQuerying) {
                [weakself.registrationManager restartRegistrationIfRequired];
            }
            
            [weakself.requestQueue setTransportQueuePaused:NO];
        }];
        
        [_reachabilityMonitor setUnreachableBlock:^(Reachability* reachability) {
            [weakself.requestQueue setTransportQueuePaused:YES];
        }];
        
        _status = PHNMeasurementServiceStatusAwaitingInitialise;
    }
    
    return self;
}

- (instancetype) init
{
    self = [self initWithConfiguration:[[PHNMeasurementServiceConfiguration alloc] init]];
    
    return self;
}

#pragma mark - public methods

- (void) startSessionWithAdvertiserID:(NSString*)advertiserID andCampaignID:(NSString*)campaignID{
    
    [self taskForSessionStartWithAdvertiserId:advertiserID andCampaignId:campaignID];
}


- (void) trackEvent:(PHNEvent*)event
{
    if (self.status != PHNMeasurementServiceStatusInactive)
    {
        PHNMeasurementServiceInternal* __weak weakself = self;
        [weakself.trackingSessionQueue addOperationWithBlock:^{
            
            @try {
                
                [PHNLog log:@"queueing event:  %@", [event description]];
                PHNEventRequest* eventrequest = [[PHNEventRequest alloc] initWithEvent:event campaignID:self.campaignID andAdvertiserID:self.advertiserID];
                [weakself.requestQueue addRequest:eventrequest];
            }
            @catch (NSException* exception) {
                [PHNLog log:@"caught unexpected exception: %@", [exception description]];
            }
        }];
    }
    else {
        [PHNLog log:@"Ignoring event as measurement service is inactive."];
    }
}

- (NSURL*) processDeepLinkWithURL:(NSURL*)deepLink
{
    @try {
        PHNDeepLinkProcessor* processor= [[PHNDeepLinkProcessor alloc] init];
        
        NSURL* filteredurl = [processor processsURL:deepLink];
        
        //grab the mobile tracking id, or the camref.
        if (processor.processedTrackingID) {
            
            [PHNLog log:@"retrieved tracking ID - %@", processor.processedTrackingID];
            [self setTrackingID:processor.processedTrackingID];
            [PHNMobileTrackingID storeID:processor.processedTrackingID];
            
        }
        else if (processor.processedCamref) {
            
            [PHNLog log:@"retrieved camref - %@", processor.processedCamref];
            self.camref = processor.processedCamref;
            [[NSUserDefaults standardUserDefaults] setObject:processor.processedCamref forKey:kPHGTrackingServiceCamRef];
        }
        
        //if you've recieved a camref or a trackingid
        if (processor.processedTrackingID || processor.processedCamref) {
            
            self.trackingActive = @(YES);
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPHGTrackingServiceActiveKey];
            return filteredurl;
        }
        else {
            return nil;
        }
    }
    @catch (NSException* exception) {
        [PHNLog log:@"caught unexpected exception: %@", [exception description]];
        return nil;
    }
}

#pragma mark - private methods

- (BFTask*) taskForEventTracking:(PHNEvent*)event {
    BFExecutor* executor = [BFExecutor executorWithOperationQueue:self.trackingSessionQueue];
    __weak typeof(self) weakself = self;
    
    return [BFTask taskFromExecutor:executor withBlock:^id _Nonnull {
        if (self.status != PHNMeasurementServiceStatusInactive) {
            @try {
                PHNEventRequest* eventrequest = [[PHNEventRequest alloc] initWithEvent:event campaignID:self.campaignID andAdvertiserID:self.advertiserID];
                [weakself.requestQueue addRequest:eventrequest];
            }
            @catch (NSException* exception) {
                [PHNLog log:@"caught unexpected exception: %@", [exception description]];
            }
        }
        
        return nil;
    }];
}

- (BFTask*) taskForSessionStartWithAdvertiserId:(NSString*)advertiserId andCampaignId:(NSString*)campaignId
{
    BFExecutor* executor = [BFExecutor executorWithOperationQueue:self.trackingSessionQueue];
    __weak typeof(self) weakself = self;
    
    return [BFTask taskFromExecutor:executor withBlock:^id _Nonnull{
        @try{
            
            weakself.advertiserID = advertiserId;
            weakself.campaignID = campaignId;
            weakself.mobileTrackingID = [PHNMobileTrackingID getID];
            weakself.status = [weakself defaultStartingStatus];
            
            switch (weakself.status) {
                case PHNMeasurementServiceStatusQuerying://tracking needs to query the API to get mobiletrackingID
                    
                    [PHNLog log:@"Querying MTID"];
                    
                    //clear request queue tracking id
                    weakself.requestQueue.trackingID = nil;
                    
                    //if a camref is available, we should always include it.
                    weakself.registrationManager.camref = weakself.camref;
                    
                    //if it's available, we should include an idfa.
                    BOOL idfaisavailable = [weakself shouldRegisterWithIdfa];
                    
                    if (idfaisavailable) {
                        weakself.registrationManager.idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                    }
                    
                    if ([weakself shouldRegisterWithUUID:idfaisavailable]) {
                        weakself.registrationManager.uuid = [[[NSUUID alloc] init] UUIDString];
                    }
                    
                    //include the install value in the registration
                    weakself.registrationManager.installed = weakself.installed;
                    
                    //make the registration request
                    [weakself.registrationManager startRegistrationWithAdvertiserID:weakself.advertiserID
                                                                         campaignID:weakself.campaignID
                                                               activeFingerprinting:weakself.configuration.activeFingerprint];
                    
                    break;
                case PHNMeasurementServiceStatusActive: //tracking setup is complete
                    
                    [PHNLog log:@"MTID is available, starting session."];
                    
                    weakself.requestQueue.trackingID = weakself.mobileTrackingID;
                    
                    //are we connected to the interwebs?
                    if (weakself.reachabilityMonitor.isReachable) {
                        weakself.requestQueue.transportQueue.isPaused = NO;
                    }
                    
                    if ([weakself.delegate respondsToSelector:@selector(measurementServiceDidInitialise:)]) {
                        dispatch_async(dispatch_get_main_queue() , ^{
                            [weakself.delegate measurementServiceDidInitialise:weakself];
                        });
                    }
                    
                default: //inactive or setup incomplete
                    
                    [PHNLog log:@"MMK inactive"];
                    
                    [self.reachabilityMonitor stopNotifier];
                    break;
            }
        }
        @catch(NSException* exception) {
            [PHNLog log:@"caught unexpected exception: %@", [exception description]];
        }
        
        return nil;
    }];
}

- (BFTask*) taskForFailedAttributionWithCamref:(NSString* _Nullable) camref {
    BFExecutor* executor = [BFExecutor executorWithOperationQueue:self.trackingSessionQueue];
    __weak typeof(self) weakself = self;
    
    return [BFTask taskFromExecutor:executor withBlock:^id _Nonnull{
        
        [PHNLog log:@"failed attribution to affiliate activity."];
        
        //guard for a registration that's been triggered in the wrong status, or perhaps that's been superceded by a new url.
        if (weakself.status == PHNMeasurementServiceStatusQuerying) {
            
            //clear stored camref if it matches the request's camref. (guard against timing/multiple request issues.)
            if (weakself.camref && camref && [weakself.camref isEqualToString:camref]) {
                weakself.camref = nil;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPHGTrackingServiceCamRef];
            }
            
            //if you have a prior mobile tracking id, revert to using that one.
            if (weakself.mobileTrackingID) {
                
                [PHNLog log:@"reverting to previous MTID"];
                
                weakself.status = PHNMeasurementServiceStatusActive;
                weakself.requestQueue.trackingID = self.mobileTrackingID;
                //self.requestQueue.isQueuePaused = NO;
                
                if ([weakself.delegate respondsToSelector:@selector(measurementServiceDidInitialise:)]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself.delegate measurementServiceDidInitialise:weakself];
                    });
                }
            }
            else { //no prior affiliate activity, no prior mobile tracking id.
                
                [PHNLog log:@"no prior affiliate activity, Measurement Service will go inactive"];
                
                weakself.status = PHNMeasurementServiceStatusInactive;
                
                weakself.trackingActive = @(NO);
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPHGTrackingServiceActiveKey];
                
                //if they have any events, clear them.
                [weakself.requestQueue clearQueue];
            }
        }
        
        return nil;
    }];
}

- (BFTask*) taskForSucessfulAttributionWithMobileTrackingId:(NSString*)mobileTrackingId deepLink:(NSURL *)deepLink usingCamref:(NSString *)camref {
    BFExecutor* executor = [BFExecutor executorWithOperationQueue:self.trackingSessionQueue];
    __weak typeof(self) weakself = self;
    
    return [BFTask taskFromExecutor:executor withBlock:^id _Nonnull {
        
        [PHNLog log:@"attribution sucessful"];
        
            //guard for a registration that's been triggered in the wrong status, or perhaps that's been superceded by a new url.
        if (weakself.status == PHNMeasurementServiceStatusQuerying) {
            
            
            [PHNLog log:@"Measurement service is active."];
        
            //set internal state
            weakself.status = PHNMeasurementServiceStatusActive;
            [weakself setTrackingID:mobileTrackingId];
            
            //set up the tracking queue
            weakself.requestQueue.trackingID = mobileTrackingId;
            
            //set externally stored state.
            weakself.trackingActive = @(YES);
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPHGTrackingServiceActiveKey];
            [PHNMobileTrackingID storeID:mobileTrackingId];
            
            //clear stored camref if it matches the request's camref. (guard against timing/multiple request issues.)
            if (weakself.camref && camref && [weakself.camref isEqualToString:camref]) {
                weakself.camref = nil;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPHGTrackingServiceCamRef];
            }
            
            //trigger initialisation delegate call
            if ([weakself.delegate respondsToSelector:@selector(measurementServiceDidInitialise:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                               [weakself.delegate measurementServiceDidInitialise:weakself];
                });
            }
            
            //rebuild deep link
            if (deepLink) {
                [weakself triggerRecoveredDeepLink:deepLink];
            }
        }
        
        return nil;
    }];
}

- (BOOL) shouldRegisterWithIdfa {
    
    //are the classes available, and post iOS 10, is the IDFA disbled for tracking.
    BOOL isidfaavailable = NSClassFromString(@"ASIdentifierManager") &&
    ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 10, .minorVersion = 0, .patchVersion = 0}]) ?
    [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled] : YES;
    
    return self.configuration.recordIDFA && isidfaavailable && [[ASIdentifierManager sharedManager] advertisingIdentifier];
}

- (BOOL) shouldRegisterWithUUID:(BOOL)isIdfaAvailable {
    return self.configuration.activeFingerprint && ! isIdfaAvailable;
}

/**
 * sets a tracking ID.
 */
- (void) setTrackingID:(NSString *)trackingID {
    
    //store it for the class.
    self.mobileTrackingID = trackingID;
    
    //make sure the event queue has it.
    self.requestQueue.trackingID = trackingID;
}

- (PHNMeasurementServiceStatus) defaultStartingStatus {
    
    if (self.camref) {
        return PHNMeasurementServiceStatusQuerying;
    }
    else if (self.mobileTrackingID) {
        return PHNMeasurementServiceStatusActive;
    }
    else if (! ((self.trackingActive) ? [self.trackingActive boolValue] : YES)) {
        return PHNMeasurementServiceStatusInactive;
    }
    else {
        return PHNMeasurementServiceStatusQuerying;
    }
    
}

- (void) triggerRecoveredDeepLink:(NSURL*)deepLink
{
    BOOL triggerdeeplink = [self.delegate respondsToSelector:@selector(measurementServiceWillOpenDeepLink:)] ?
        [self.delegate measurementServiceWillOpenDeepLink:deepLink] : YES;
    
    if (triggerdeeplink) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]
                && [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion > 9) {
                
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(application:openURL:options:)]) {
                    
                    NSMutableDictionary<NSString *, id>* options = [NSMutableDictionary dictionary];
                    
                    if ([[NSBundle mainBundle] bundleIdentifier]) {
                        options[UIApplicationOpenURLOptionsSourceApplicationKey] = [[NSBundle mainBundle] bundleIdentifier];
                    }
                    
                    [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] openURL:deepLink options:options];
                }
            }
            else if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
                
                [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] openURL:deepLink sourceApplication:[[NSBundle mainBundle] bundleIdentifier] annotation:@{}];
            }
        });
        
    }
}

#pragma mark - PHGActiveFingerprinterDelegate

- (void) registrationManager:(PHNRegistrationManager *)registrationManager attributionDidFailUsingCamref:(NSString *)camref
{
    [self taskForFailedAttributionWithCamref:camref];
}

- (void) registrationManager:(PHNRegistrationManager *)registrationManager didAttribute:(NSString *)mobileTrackingID withDeepLink:(NSURL *)deepLink usingCamref:(NSString *)camref
{
    [self taskForSucessfulAttributionWithMobileTrackingId:mobileTrackingID deepLink:deepLink usingCamref:camref];
}


#pragma mark - debug methods.


+ (void) clearMeasurementServiceIDs {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPHGTrackingServiceActiveKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPHGTrackingServiceCamRef];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [PHNMobileTrackingID deleteID];
}

- (void) clearMeasurementServiceIDs
{
    self.mobileTrackingID = nil;
    [PHNMeasurementServiceInternal clearMeasurementServiceIDs];
}

#ifdef DEBUG

- (void) fakeClick
{
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLRequest* request = self.configuration.isDebug ? [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.prf.local/click/camref:iaAv/"]] :
    [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://m.prfhn.com/click/camref:1100l4PK"]];

    [[session dataTaskWithRequest:request] resume];
}

#endif

@end
