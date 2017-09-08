//
//  PHGHostController.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 27/02/2015.
//
//

#import <Foundation/Foundation.h>

@interface PHNHostHelper : NSObject

@property(nonatomic, assign) BOOL isDebug;

- (NSString*) hostForTracking;
- (NSString*) urlStringForTracking;

@end
