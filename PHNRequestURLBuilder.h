//
//  PHNURLRequestBuilder.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 23/03/2016.
//
//

#import <Foundation/Foundation.h>

@class PHNHostHelper;

@interface PHNRequestURLBuilder : NSObject

+ (PHNRequestURLBuilder*) builderWithHostHelper:(PHNHostHelper*)helper;

- (NSURLRequest*) POSTWithPath:(NSString*)path andJSONBody:(NSDictionary*)body;

- (PHNRequestURLBuilder*) initWithHostHelper:(PHNHostHelper*)helper;



@end
