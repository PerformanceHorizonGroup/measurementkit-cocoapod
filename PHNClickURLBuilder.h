//
//  PHNMeasurementURLBuilder.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 18/02/2016.
//
//

@class PHNHostHelper;

#import <Foundation/Foundation.h>

@interface PHNClickURLBuilder : NSObject

+ (PHNClickURLBuilder*) URLBuilderWithHostHelper:(PHNHostHelper*)helper;
- (instancetype) initWithHostHelper:(PHNHostHelper*)helper;

@property(nonatomic, retain) NSURL* destination;
@property(nonatomic, retain) NSURL* deepLink;
@property(nonatomic, retain) NSString* camref;
@property(nonatomic, assign) BOOL isDeepLinkSkipped;

- (void) putAliasWithKey:(NSString*)key andValue:(NSString*)value;
- (NSURL*) build;

@end
