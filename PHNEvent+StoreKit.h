//
//  PHNEvent+StoreKit.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 21/03/2016.
//
//

#import <Foundation/Foundation.h>
#import "PHNEvent.h"
#import <StoreKit/StoreKit.h>

@interface PHNEvent (StoreKit)

/**
 convenience initializer for event generated from store kit product
 @param product The product to generate the event from
 @param quantity The quantity of product sold
 @return the initialized event
 */
+ (instancetype) eventWithProduct:(SKProduct*)product andQuantity:(NSInteger)quantity;

@end
