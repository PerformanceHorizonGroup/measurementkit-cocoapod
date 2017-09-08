//
//  PHGMobileTrackingID.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 11/03/2015.
//
//

#import "PHNMobileTrackingID.h"

#import <Security/Security.h>

@implementation PHNMobileTrackingID

+ (NSString*) getID {
    
    NSMutableDictionary* keychainquery = [self baseQuery];
    
    [keychainquery setObject:@YES forKey:(__bridge id)kSecReturnData];
    [keychainquery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    CFTypeRef keychainresult = NULL;
    
    int status;
    
    status =  SecItemCopyMatching((__bridge CFDictionaryRef)keychainquery, &keychainresult);
    
    if (keychainresult == NULL) {
        return nil;
    } 
    else
    {
        NSString* idstring = [[NSString alloc] initWithData:(__bridge NSData*)keychainresult encoding:NSUTF8StringEncoding];
        CFRelease(keychainresult);
        return idstring;
    }
}

+ (void) deleteID
{
    NSMutableDictionary* keychainquery = [PHNMobileTrackingID baseQuery];
    
    SecItemDelete((__bridge CFDictionaryRef)keychainquery);
}

+ (void) storeID:(NSString*)string {
    
    [PHNMobileTrackingID deleteID];
    
    NSData* encodedstring = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary* query = [self baseQuery];
    
    [query setObject:encodedstring forKey:(__bridge id)kSecValueData];
    [query setObject:(__bridge id) kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    [query setObject:@"Identifer for PHG Mobile Tracking" forKey:(__bridge id)kSecAttrDescription];
    
    SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}

+ (NSMutableDictionary*) baseQuery
{
    NSMutableDictionary* keychainquery = [NSMutableDictionary dictionary];
    
    [keychainquery setObject:@"com.performancehorizon.phgmt" forKey:(__bridge id)kSecAttrService];
    [keychainquery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    return keychainquery;
}

@end
