//
//  PHNMeasurementURLBuilder.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 18/02/2016.
//
//
#import "PHNHostHelper.h"

#import "PHNClickURLBuilder.h"

@interface PHNClickURLBuilder()

@property(nonatomic, retain) PHNHostHelper* helper;
@property(nonatomic, retain) NSMutableDictionary<NSString*, NSString*>* aliases;

@end

@implementation PHNClickURLBuilder

+ (PHNClickURLBuilder*) URLBuilderWithHostHelper:(PHNHostHelper*)helper {
    return [[PHNClickURLBuilder alloc] initWithHostHelper:helper];
}

- (instancetype) initWithHostHelper:(PHNHostHelper*)helper {
    if (self = [super init]) {
        self.helper = helper;
        self.isDeepLinkSkipped = false;
        self.aliases = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (BOOL) isValid {
    return self.helper && self.camref && self.destination;
}

- (void) putAliasWithKey:(NSString*)key andValue:(NSString*)value {
    self.aliases[key] = value;
}

- (NSURL*) build {
    if (![self isValid]) {
        return nil;
    }
    
    //construction
    NSString* basestring = [NSString stringWithFormat:@"%@/click/camref:%@/destination:%@",
                           [self.helper urlStringForTracking],
                            self.camref,
                           [[self.destination absoluteString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
    
    
    NSURLComponents* urlcomponents = [[NSURLComponents alloc] initWithString:basestring];
    
    NSMutableArray<NSURLQueryItem*>* query = [[NSMutableArray alloc] init];
    
    for (NSString* key in self.aliases) {
        [query addObject:[[NSURLQueryItem alloc] initWithName:key value:self.aliases[key]]];
    }
    
    if (self.deepLink) {
        [query addObject:[[NSURLQueryItem alloc] initWithName:@"deep_link" value:[self.deepLink absoluteString]]];
    }
    
    if (self.isDeepLinkSkipped) {
        [query addObject:[[NSURLQueryItem alloc] initWithName:@"skip_deep_link" value:@"true"]];
    }
    
    urlcomponents.queryItems = query;
    
    return [urlcomponents URL];
}

@end
