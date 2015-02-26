//
//  PHGMobileTrackingSale.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import <Foundation/Foundation.h>


/**
 PHGMobileTracking sale represents a conversion item which forms part of an event.  
 
 An example of this might be a paid registration, or a purchase.
 */
@interface PHGMobileTrackingSale : NSObject

/**
 initialises with catagory and value
 @param category Category of the sale.
 @param value The sales value
 @return sale.
 */
- (instancetype) initWithCategory:(NSString*)category andValue:(NSNumber*)value;

/**
 returns sale with given category and value.
 @param category Category of the sale
 @param value Value of the sale
 @return sale
 */
+ (instancetype) saleWithCategory:(NSString*)category andValue:(NSNumber*)value;

/**
 returns sale with given category, value, SKU, and quantity.
 @param category Category of the sale
 @param value Value of the sale
 @param sku SKU (stock keeping unit) of the sale
 @param quantity number of items that make up the sale
 @return sale
 */
+ (instancetype) saleWithCategory:(NSString*)category value:(NSNumber*)value sku:(NSString*)sku andQuantity:(NSInteger)quantity;

/**
 sales category
 */
@property(readonly, nonatomic, retain) NSString* category;

/**
 sales value
 */
@property(readonly, nonatomic, retain) NSNumber* value;

/**
 SKU for the sale.
 */
@property(nonatomic, retain) NSString* sku;

/**
 Quantity of items that make up the sale.
 */
@property(nonatomic, assign) NSInteger quantity;

@end

