//
//  PHNRegistrationManager.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 19/04/2016.
//
//

#import "PHNEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class PHNRegistrationManager;

@class PHNAPIRequestQueue;
@class PHNActiveFingerprinter;

@protocol  PHNRegistrationManagerDelegate <NSObject>

- (void) registrationManager:(PHNRegistrationManager*)registrationManager
                didAttribute:(NSString*)mobileTrackingID
                withDeepLink:(NSURL* _Nullable)deepLink
                 usingCamref:(NSString* _Nullable)camref;

- (void) registrationManager:(PHNRegistrationManager*)registrationManager
    attributionDidFailUsingCamref:(NSString* _Nullable)camref;

@end




@interface PHNRegistrationManager : NSObject

@property(nonatomic, retain) NSString* _Nullable camref;
@property(nonatomic, retain) NSNumber* _Nullable installed;

@property(nonatomic, retain) NSString* _Nullable idfa;
@property(nonatomic, retain) NSString* _Nullable uuid;

@property(nonatomic, weak) id<PHNRegistrationManagerDelegate> delegate;

- (instancetype) initWithRequestQueue:(PHNAPIRequestQueue*)queue
               andActiveFingerprinter:(PHNActiveFingerprinter*)activeFingerprinter;

- (void) startRegistrationWithAdvertiserID:(NSString*)advertiserID
                                campaignID:(NSString*)campaignID
                      activeFingerprinting:(BOOL)active;

- (void) restartRegistrationIfRequired;

@end


NS_ASSUME_NONNULL_END