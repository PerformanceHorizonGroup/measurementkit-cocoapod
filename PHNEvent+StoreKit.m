//
//  PHNEvent+StoreKit.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 21/03/2016.
//
//

#import "PHNEvent+StoreKit.h"
#import "PHNSale.h"


@implementation PHNEvent (StoreKit)

+ (instancetype) eventWithProduct:(SKProduct*)product andQuantity:(NSInteger)quantity;
{
    NSString* localecurrency = [product.priceLocale objectForKey:NSLocaleCurrencyCode] ?: @"USD";
    
    return [[self alloc] initWithSale:[PHNSale saleWithCategory:product.localizedTitle
                                                          value:product.price
                                                            sku:product.productIdentifier
                                                    andQuantity:quantity]
                           ofCurrency:localecurrency];
}

@end
