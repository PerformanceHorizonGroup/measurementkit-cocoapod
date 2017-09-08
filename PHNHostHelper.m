//
//  PHGHostController.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 27/02/2015.
//
//

#import "PHNHostHelper.h"

@implementation PHNHostHelper

- (instancetype) init {
    if (self = [super init]) {
        _isDebug = false;
    }
    return self;
}

- (NSString*) hostForTracking
{
    if (self.isDebug) {
        return @"m.prf.local";
    }
    else
        return @"m.prf.hn";

}

- (NSString*) urlStringForTracking
{
    if (self.isDebug) {
        return @"http://m.prf.local";
    }
    else {
        return @"https://m.prf.hn";
    }
}

@end
