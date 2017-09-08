//
//  PHNRegistrationManager.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 19/04/2016.
//
//

#import "PHNRegistrationManager.h"

#import "PHNDeviceFingerprinter.h"
#import "PHNActiveFingerprinter.h"
#import "PHNRegistrationRequestBuilder.h"
#import "PHNAPIRequestQueue.h"
#import "PHNAPIRequest.h"

#import "PHNLog.h"

static NSString* kPHGTrackingServiceIDjsonKey = @"mobiletracking_id";

@interface PHNRegistrationManager() <PHNActiveFingerprinterDelegate>

- (instancetype) initWithRequestQueue:(PHNAPIRequestQueue*)queue
                  deviceFingerprinter:(PHNDeviceFingerprinter*)deviceFingerprinter
                  andActiveFingerprinter:(PHNActiveFingerprinter*)activeFingerprinter;

//inputs
@property(nonatomic, retain) NSString* campaignID;
@property(nonatomic, retain) NSString* advertiserID;

//dependencies
@property(nonatomic, retain) PHNAPIRequestQueue* requestQueue;
@property(nonatomic, retain) PHNDeviceFingerprinter* deviceFingerprinter;
@property(nonatomic, retain) PHNActiveFingerprinter* activeFingerprinter;

//simple management if a registration has been completed in it's entirety.
@property(nonatomic, assign) BOOL registrationComplete;
@property(nonatomic, assign) BOOL shouldActiveFingerprint;


@end

@implementation PHNRegistrationManager

- (instancetype) initWithRequestQueue:(PHNAPIRequestQueue*)queue
                  deviceFingerprinter:(PHNDeviceFingerprinter*)deviceFingerprinter
                  andActiveFingerprinter:(PHNActiveFingerprinter*)activeFingerprinter;
{
    if (self = [super init]) {
        _registrationComplete = YES;
        _shouldActiveFingerprint = NO;
        
        _requestQueue = queue;
        _deviceFingerprinter = deviceFingerprinter;
        _activeFingerprinter = activeFingerprinter;
        _activeFingerprinter.delegate = self;
    }
    
    return self;
}

- (instancetype) initWithRequestQueue:(PHNAPIRequestQueue*)queue
               andActiveFingerprinter:(PHNActiveFingerprinter*)activeFingerprinter {
    
    return [self initWithRequestQueue:queue
                  deviceFingerprinter:[[PHNDeviceFingerprinter alloc] init]
               andActiveFingerprinter:activeFingerprinter];
    
}


- (void) startRegistrationWithAdvertiserID:(NSString*)advertiserID
                             campaignID:(NSString*)campaignID
                    activeFingerprinting:(BOOL)active
{
    self.registrationComplete= NO;
    self.shouldActiveFingerprint = active;
    
    self.advertiserID = advertiserID;
    self.campaignID = campaignID;
    
    //any fingerprints in progess with dependencies should be cancelled.
    [self.activeFingerprinter clearCompleted];
    [self.requestQueue cancelRequestWithIdentifier:@"register"];
    
    if (active && self.idfa) {
        [self.activeFingerprinter fingerprintWithIDFA:self.idfa];
    }
    else if (active && self.uuid){
        [self.activeFingerprinter fingerprintWithUUID:self.uuid];
    }
    else {
        [self startRegistrationRequest];
    }
}

- (void) restartRegistrationIfRequired {
    
    if (self.registrationComplete) {
        return;
    }
    else {
        
        if (self.shouldActiveFingerprint && (self.idfa || self.uuid) &&
            !self.activeFingerprinter.fingerprintComplete) {
                
            if (!self.activeFingerprinter.fingerprintInProgress) {
                [self.activeFingerprinter fingerprint];
            }
        }
        else if(![self.requestQueue requestInProgessWithIdentifier:@"register"]) {
            [self startRegistrationRequest];
        }
    }
}

- (void) startRegistrationRequest {
    
    PHNAPIRequest* registrationrequest = [self registrationRequest];
    
    if (registrationrequest) {
        PHNRegistrationManager* __weak weakself = self;
        registrationrequest.handler =^(PHNAPIRequest *request, NSData *result, NSError *error) {
            [weakself registrationRequest:request didCompleteWithResult:result withError:error];
        };
        
        [self.requestQueue executeRequest:registrationrequest];
    }
    else {
        [PHNLog log:@"generated invalid registration request."];
    }
}

- (PHNAPIRequest* _Nullable) registrationRequest
{
    PHNRegistrationRequestBuilder* builder = [[PHNRegistrationRequestBuilder alloc] init];
    
    //collect a registration request
    [builder putAdvertiserID:self.advertiserID];
    [builder putCampaignID:self.campaignID];
    [builder putIDFA:self.idfa];
    [builder putUUID:self.uuid];
    [builder putCamref:self.camref];
    [builder putFingerprint:[self.deviceFingerprinter fingerprint]];
    
    // if we're active fingerprinting, we should allow for failure of the /alias call.
    // (no way of telling if that request is sucesful)
    if (self.idfa || self.uuid) {
        [builder putFingerprintFallback];
    }
    
    //if the user has inputted an "install" value, add to registration request.
    if (self.installed) {
        [builder putInstalled:[self.installed boolValue]];
    }
    
    NSDictionary* registrationparameters = [builder build];
    
    //guard for invalid parameters
    if (!registrationparameters)
        return nil;
    
    PHNAPIRequest* registration = [[PHNAPIRequest alloc] initWithPath:@"/register" andParameters:registrationparameters];
    
    registration.requestIdentifier = @"register";
    
    return registration;
}

- (void) registrationRequest:(PHNAPIRequest*)request didCompleteWithResult:(NSData*)result withError:(NSError*)error
{
    @try{

        if (self.registrationComplete || (self.shouldActiveFingerprint && self.activeFingerprinter.fingerprintInProgress)) {
            return;
        }
        
        if (error) {
            [PHNLog log:@"registration response error."];
            return;
        }
        
        NSError* jsonerror;
        NSDictionary* responsedictionary = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonerror];
        
        //we've completed registration.
        self.registrationComplete = YES;
        
        //second failure guard, failure in decoding, or missing the required mobile tracking id param.
        if (jsonerror || !responsedictionary[kPHGTrackingServiceIDjsonKey]) {
            
            [PHNLog log:@"unexpected response from registration."];
            return;
        }
        
        //failure case, the API has responded that there's no affiliate activity for this device. (based on the previous registration attempt)
        if ([responsedictionary[kPHGTrackingServiceIDjsonKey] isKindOfClass:[NSNumber class]]
            && [responsedictionary[kPHGTrackingServiceIDjsonKey] boolValue] == NO) {
            
            if ([self.delegate respondsToSelector:@selector(registrationManager:attributionDidFailUsingCamref:)]) {
                [self.delegate registrationManager:self attributionDidFailUsingCamref:self.camref];
            }
            
        }
        else//sucessful registration
        {
            NSURL* deeplink = responsedictionary[@"deep_link"] ?
                [[NSURL alloc] initWithString:[responsedictionary[@"deep_link"]
                                               stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] : nil;
            
            if ([self.delegate respondsToSelector:@selector(registrationManager:didAttribute:withDeepLink:usingCamref:)]) {
                [self.delegate registrationManager:self
                                      didAttribute:[responsedictionary[kPHGTrackingServiceIDjsonKey] description]
                                      withDeepLink:deeplink
                                       usingCamref:self.camref];
            }
        }
    }
    @catch (NSException* exception) {
        [PHNLog log:@"registration manager - caught unexpected exception on registration request: %@", [exception description]];
    }
}

#pragma mark - PHNActiveFingerprinterDelegate

- (void) activeFingerprinterDidCompleteWithResults:(NSDictionary *)dictionary {
    if (self.shouldActiveFingerprint)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startRegistrationRequest];
        });
    }
}


@end
