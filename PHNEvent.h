//
//  PHGMobileTrackingEvent.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PHNSale;

/**
 PHNEvent represents an event tracked by the mobile measurement service.
 Examples could include registration, purchases or upgrades.
 */
@interface PHNEvent : NSObject

/**
 initialize event with given category.
 @param category The event category
 @return The initialized event
*/
- (instancetype) initWithCategory:(NSString*)category;

/**
 initialize event with given sale.
 @param sale The associated sale
 @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place
 @return The initialized event
 */
- (instancetype) initWithSale:(PHNSale*)sale ofCurrency:(NSString*)currencyCode;

/**
 initialize event with given sales.
 @param sales The associated set of sales
 @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place
 @return The initialized event
 */
- (instancetype) initWithSales:(NSArray*)sales ofCurrency:(NSString*)currencyCode;

/**
 convenience initializer for event with category.
 @param category The event category
 @return The initialized event
 */
+ (instancetype) eventWithCategory:(NSString*)category;

/**
 convenience initializer for event with sale.
 @param sale The associated sale
 @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place
 */
+ (instancetype) eventWithSale:(PHNSale*)sale ofCurrency:(NSString*)currencyCode;

/**
 convenience initializer for event with given sales.
 @param sales The associated set of sales
 @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place
 @return The initialized event
 */
+ (instancetype) eventWithSales:(NSArray*)sales ofCurrency:(NSString*)currencyCode;
/**
 category of the event (corresponds to product in the exactview console interface.)
 */
@property(retain, readonly) NSString* _Nullable category;
@property(retain, readonly) NSArray<PHNSale*>* _Nullable sales;
@property(retain, readonly) NSString* _Nullable salesCurrency;

/**
 * country in which the event took place.
 */
@property(retain) NSString* _Nullable country;

/**
 * voucher code used with the event.
 */
@property(retain) NSString* _Nullable voucher;

/**
 * conversion reference for the event
 */
@property(retain) NSString* _Nullable conversionReference;

/**
 * customer reference for the event.
 */
@property(retain) NSString* _Nullable customerReference;

/**
 * customer type for the event.
 */
@property(retain) NSString* _Nullable customerType;

/**
 sets a meta item (arbitrary key value pair) for the event
 @param key Key to set
 @param value Value to set
 */
- (void) setMetaItemWithKey:(NSString*)key andValue:(NSString*)value;


@end

NS_ASSUME_NONNULL_END
