//
//  PHNRegistrationRequestBuilder.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 15/04/2016.
//
//

#import "PHNRegistrationRequestBuilder.h"

@interface PHNRegistrationRequestBuilder()

@property(nonatomic, retain) NSString* _Nullable advertiserID;
@property(nonatomic, retain) NSString* _Nullable campaignID;
@property(nonatomic, retain) NSString* _Nullable idfa;
@property(nonatomic, retain) NSString* _Nullable uuid;
@property(nonatomic, retain) NSString* _Nullable camref;
@property(nonatomic, retain) NSDictionary* _Nullable fingerprint;

@property(nonatomic, assign) Boolean shouldAddFingerprintFallback;
@property(nonatomic, assign) NSNumber* _Nullable installed;

@end

@implementation PHNRegistrationRequestBuilder

- (instancetype) init {
    if (self = [super init]) {
        _shouldAddFingerprintFallback = false;
    }
    
    return self;
}

- (instancetype _Nonnull) putAdvertiserID:(NSString* _Nullable)advertiserID {
    self.advertiserID = advertiserID;
    return self;
}

- (instancetype _Nonnull) putCampaignID:(NSString* _Nullable)campaignID {
    self.campaignID = campaignID;
    return self;
}

- (instancetype _Nonnull) putIDFA:(NSString* _Nullable)idfa {
    self.idfa = idfa;
    return self;
}

- (instancetype _Nonnull) putUUID:(NSString* _Nullable)uuid {
    self.uuid = uuid;
    return self;
}

- (instancetype _Nonnull) putCamref:(NSString* _Nullable)camref {
    self.camref = camref;
    return self;
}

- (instancetype _Nonnull) putFingerprintFallback {
    self.shouldAddFingerprintFallback = true;
    return self;
}

- (instancetype _Nonnull) putInstalled:(Boolean)installed {
    self.installed = @(installed);
    return self;
}

- (instancetype _Nonnull) putFingerprint:(NSDictionary* _Nonnull)fingerprint {
    self.fingerprint = fingerprint;
    return self;
}

- (NSDictionary* _Nullable) build {
    
    // guard for invalid build
    if (!self.advertiserID || !self.campaignID) {
        return nil;
    }
    
    NSMutableDictionary* requestparameters = [NSMutableDictionary dictionaryWithDictionary:@{@"advertiser_id":self.advertiserID,@"campaign_id":self.campaignID}];
    
    if (self.idfa) {
        requestparameters[@"IDFA"] = self.idfa;
    }
    
    if (self.uuid) {
        requestparameters[@"UUID"] = self.uuid;
    }
    
    if (self.camref) {
        requestparameters[@"camref"] = self.camref;
    }
    
    if (self.installed)
        requestparameters[@"install"] = self.installed;
    
    if (self.shouldAddFingerprintFallback) {
        requestparameters[@"fingerprint_fallback"] = @(TRUE);
    }
    
    if (self.fingerprint) {
        requestparameters[@"fingerprint"] = self.fingerprint;
    }
    
    return requestparameters;
}


@end
