//
//  PHNDeepLinkProcessor.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 09/11/2015.
//
//

#import <Foundation/Foundation.h>

@interface PHNDeepLinkProcessor : NSObject

- (NSURL*) processsURL:(NSURL*)url;

//processor results.
@property(nonatomic, readonly) NSString* processedCamref;
@property(nonatomic, readonly) NSString* processedTrackingID;

@end
