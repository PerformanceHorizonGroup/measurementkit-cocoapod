//
//  PHNAppClick.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 20/04/2016.
//
//

#import <Foundation/Foundation.h>

@interface PHNAppClick : NSObject

/**
 appends the given camref onto the url, then opens the url.
 @param url - given url to open
 @param camref - the campaign reference that encodes the publisher/campaign combination.
 @return false if the given URL can not be opened.
 @see UIApplication - openURL:
 @warning - Please note that the method does not check whether the given URL can be opened.
 */
+ (BOOL) openURL:(NSURL*)URL withCamref:(NSString*)camref;

/**
 attempts to open the given url, if, attempts to open the provided alternative.
 @param url - given url to open
 @param alternativeURL - alternative url
 @param camref - the campaign reference that encodes the publisher/campaign combination.
 @return false if the given URL can not be opened.
 @see UIApplication - openURL:
 @see UIApplication - canOpenURL:
 */
+ (BOOL) openURL:(NSURL*)URL withAlternativeURL:(NSURL*)alternativeURL andCamref:(NSString*)camref;

@end
