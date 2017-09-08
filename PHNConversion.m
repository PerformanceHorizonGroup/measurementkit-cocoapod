//
//  PHNConversion.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 31/03/2016.
//
//

#import "PHNConversion.h"
#import "PHNConversionItem.h"

@implementation PHNConversion

- (instancetype) initWithConversionItem:(PHNConversionItem*)conversionItem ofCurrency:(NSString*)currencyCode {
    return [self initWithSale:conversionItem ofCurrency:currencyCode];
}

- (instancetype) initWithConversionItems:(NSArray<PHNConversionItem*>*)conversionItems ofCurrency:(NSString*)currencyCode {
    return [self initWithConversionItems:conversionItems ofCurrency:currencyCode];
}


+ (instancetype) conversionWithCategory:(NSString*)category {
    return [[PHNConversion alloc] initWithCategory:category];
}

+ (instancetype) conversionWithConversionItem:(PHNConversionItem*)conversionItem ofCurrency:(NSString*)currencyCode {
    return [[PHNConversion alloc] initWithSale:conversionItem ofCurrency:currencyCode];
}


+ (instancetype) conversionWithConversionItems:(NSArray<PHNConversionItem*>*)conversionItems ofCurrency:(NSString*)currencyCode {
    return [[PHNConversion alloc] initWithSales:conversionItems ofCurrency:currencyCode];
}

@end
