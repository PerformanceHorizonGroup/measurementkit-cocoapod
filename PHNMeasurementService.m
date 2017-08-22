//
//  PHNMeasurementService.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 29/10/2015.
//
//



#import "PHNMeasurementService.h"
#import "PHNMeasurementServiceInternal.h"
#import "PHNMeasurementServiceConfiguration.h"
#import "PHNEvent.h"
#import "PHNConversion.h"
#import "PHNAppClick.h"

#import <objc/runtime.h>

//shared instance
PHNMeasurementService* _PHGTrackingService;

//swizzling dark magic

/*static void (*_original_Mixpanel_imp)(id self, SEL _cmd,  NSString* event, NSDictionary* properties);
static void _replacement_Track_Event(id self, SEL _cmd, NSString* event, NSDictionary* properties) {
    assert([NSStringFromSelector(_cmd) isEqualToString:@"trackEvent"]);
    
    [[PHNMeasurementService sharedInstance] trackEvent:[PHNEvent eventWithCategory:event]];
    
    ((void(*)(id,SEL, NSString*, NSDictionary*))_original_Mixpanel_imp)(self,_cmd, event, properties);
}*/

@interface PHNMeasurementService() <PHNMeasurementServiceInternalDegelate>

@property(nonatomic, retain) PHNMeasurementServiceInternal* service;

@end


@implementation PHNMeasurementService
#pragma mark - Lifecycle

+ (PHNMeasurementService*) sharedInstance
{
    
    static dispatch_once_t trackingDispatchToken;
    dispatch_once(&trackingDispatchToken, ^{
        if (!_PHGTrackingService) {
            _PHGTrackingService = [[PHNMeasurementService alloc] init];
        }
    });
    
    return _PHGTrackingService;
}

+ (void) setSharedInstance:(PHNMeasurementService*)sharedInstance
{
    _PHGTrackingService = sharedInstance;
}

- (instancetype) initWithConfiguration:(PHNMeasurementServiceConfiguration*)config
{
    if (self = [super init]) {
        _service = [[PHNMeasurementServiceInternal alloc] initWithConfiguration:config];
    }
    
    return self;
}

- (instancetype) init
{
    if (self = [super init]) {
        _service = [[PHNMeasurementServiceInternal alloc] init];
    }
    
    return self;
}

- (void) startSessionWithAdvertiserID:(NSString*)advertiserID andCampaignID:(NSString*)campaignID{
    [self.service startSessionWithAdvertiserID:advertiserID andCampaignID:campaignID];
}

- (void) trackEvent:(PHNEvent*)event {
    [self.service trackEvent:event];
}

- (void) trackConversion:(PHNConversion*)conversion {
    [self.service trackEvent:conversion];
}

- (NSURL*) processDeepLinkWithURL:(NSURL*)deepLink {
    return [self.service processDeepLinkWithURL:deepLink];
}

+ (BOOL) openURL:(NSURL*)URL withCamref:(NSString*)camref {
    return [PHNAppClick openURL:URL withCamref:camref];
}

+ (BOOL) openURL:(NSURL *)URL withAlternativeURL:(NSURL *)alternativeURL andCamref:(NSString *)camref {
    return [PHNAppClick openURL:URL withAlternativeURL:alternativeURL andCamref:camref];
}

- (void) setDelegate:(id<PHNMeasurementServiceDegelate>)delegate
{
    _delegate = delegate;
    
    if (_delegate) {
        self.service.delegate = self;
    }
}

- (void) clearMeasurementServiceIDs {
    [self.service clearMeasurementServiceIDs];
}

- (void) setInstalled:(BOOL)installed
{
    self.service.installed = @(installed);
}

#pragma mark PHNMeasurementServiceInternalDelegate

- (void) measurementServiceDidInitialise:(PHNMeasurementServiceInternal*)service {
    
    if ([self.delegate respondsToSelector:@selector(measurementServiceDidInitialise:)]) {
        [self.delegate measurementServiceDidInitialise:self];
    }
}

- (BOOL) measurementServiceWillOpenDeepLink:(NSURL*)deepLinkUrl
{
    if ([self.delegate respondsToSelector:@selector(measurementService:willOpenDeepLink:)]) {
        return [self.delegate measurementService:self willOpenDeepLink:deepLinkUrl];
    }
    
    return NO;
}

@end
