//
//  PHNConversion.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 31/03/2016.
//
//

#import "PHNEvent.h"

@class PHNConversionItem;

@interface PHNConversion : PHNEvent

/**
 initialize conversion with given conversion item.
 @param conversionItem The associated conversion item
 @param currencyCode ISO-4217 (3-letter) currency code in which the conversion takes place
 @return The initialized event
 */
- (instancetype) initWithConversionItem:(PHNConversionItem*)conversionItem ofCurrency:(NSString*)currencyCode;

/**
 initialize conversion with given conversion items.
 @param conversionItems The associated set of conversion items
 @param currencyCode ISO-4217 (3-letter) currency code in which the conversion takes place
 @return The initialized event
 */
- (instancetype) initWithConversionItems:(NSArray<PHNConversionItem*>*)conversionItems ofCurrency:(NSString*)currencyCode;

/**
 convenience initializer for conversion with category.
 @param category The event category
 @return The initialized event
 */
+ (instancetype) conversionWithCategory:(NSString*)category;

/**
 convenience initializer for conversion with conversion items.
 @param conversionItem The associated conversion item
 @param currencyCode ISO-4217 (3-letter) currency code in which the conversion takes place
 */
+ (instancetype) conversionWithConversionItem:(PHNConversionItem*)conversionItem ofCurrency:(NSString*)currencyCode;

/**
 convenience initializer for conversion with given conversion items.
 @param conversionItems The associated set of sales
 @param currencyCode ISO-4217 (3-letter) currency code in which the conversion takes place
 @return The initialized event
 */
+ (instancetype) conversionWithConversionItems:(NSArray<PHNConversionItem*>*)conversionItems ofCurrency:(NSString*)currencyCode;

@end
