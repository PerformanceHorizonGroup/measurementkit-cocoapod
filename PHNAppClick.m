//
//  PHNAppClick.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 20/04/2016.
//
//

#import "PHNAppClick.h"
#import <UIKit/UIKit.h>
#import "PHNHostHelper.h"
#import "PHNClickURLBuilder.h"

#import <AdSupport/AdSupport.h>

@implementation PHNAppClick

+ (BOOL) openURL:(NSURL*)URL withCamref:(NSString*)camref
{
    //simple start.  Append camref as query parameter.
    NSURLComponents* urlcomponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSArray<NSURLQueryItem*>* queryitems = urlcomponents.queryItems ?: [NSArray array];
    urlcomponents.queryItems = [queryitems arrayByAddingObject:[NSURLQueryItem queryItemWithName:@"phn_camref" value:camref]];
    
    //prepare URL for sending
    NSURL* url = [urlcomponents URL];
    
    return [[UIApplication sharedApplication] openURL:url];
}

+ (BOOL) openURL:(NSURL*)URL withAlternativeURL:(NSURL*)alternativeURL andCamref:(NSString*)camref
{
    NSURLComponents* urlcomponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSArray<NSURLQueryItem*>* queryitems = urlcomponents.queryItems ?: [NSArray array];
    urlcomponents.queryItems = [queryitems arrayByAddingObject:[NSURLQueryItem queryItemWithName:@"phn_camref" value:camref]];
    
    //prepare URL for sending
    NSURL* url = [urlcomponents URL];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        return [[UIApplication sharedApplication] openURL:url];
    }
    else {
        
        PHNHostHelper* helper = [[PHNHostHelper alloc] init];
        PHNClickURLBuilder* builder = [PHNClickURLBuilder URLBuilderWithHostHelper:helper];
        
        builder.camref = camref;
        builder.deepLink = URL;
        builder.destination = alternativeURL;
        builder.isDeepLinkSkipped = true;
        
        //if the idfa is available, get it.
        if (NSClassFromString(@"ASIdentifierManager")) {
            ASIdentifierManager* adsupportmanager = [ASIdentifierManager sharedManager];
            [builder putAliasWithKey:@"idfa" andValue:[[adsupportmanager advertisingIdentifier] UUIDString]];
        }
        
        return [[UIApplication sharedApplication] openURL:[builder build]];
    }
}

@end
