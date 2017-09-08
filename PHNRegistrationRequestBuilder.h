//
//  PHNRegistrationRequestBuilder.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 15/04/2016.
//
//

#import "PHNEvent.h"

@interface PHNRegistrationRequestBuilder : NSObject

- (instancetype _Nonnull) putAdvertiserID:(NSString* _Nullable)advertiserID;
- (instancetype _Nonnull) putCampaignID:(NSString* _Nullable)campaignID;
- (instancetype _Nonnull) putIDFA:(NSString* _Nullable)idfa;
- (instancetype _Nonnull) putUUID:(NSString* _Nullable)uuid;
- (instancetype _Nonnull) putCamref:(NSString* _Nullable)camref;

- (instancetype _Nonnull) putFingerprint:(NSDictionary* _Nonnull)fingerprint;

- (instancetype _Nonnull) putFingerprintFallback;
- (instancetype _Nonnull) putInstalled:(Boolean)installed;

- (NSDictionary* _Nullable) build;

@end
