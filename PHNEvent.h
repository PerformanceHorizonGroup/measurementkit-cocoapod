//
//  PHGMobileTrackingEvent.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import <Foundation/Foundation.h>

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
 convenience initializer for with given sales.
 @param sales The associated set of sales
 @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place
 @return The initialized event
 */
+ (instancetype) eventWithSales:(NSArray*)sales ofCurrency:(NSString*)currencyCode;

/**
 category of the event (corresponds to product in the exactview console interface.)
 */
@property(retain, readonly) NSString* category;

/**
 add sale (PHG usually terms this a conversion item) to an event.
 @param sale A sale
 @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place.
 @warning will overwrite any currently attached sales, if present.
 */
- (void) addSale:(PHNSale*)sale ofCurrency:(NSString*)currencyCode;

/**
 add array of sales to an event.
 @param sales NSArray of sales
 @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place.
  @warning will overwrite any currently attached sales, if present.
 */
- (void) addSales:(NSArray*)sales ofCurrency:(NSString*)currencyCode;

@end
