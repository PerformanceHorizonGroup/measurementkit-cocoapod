//
//  PHGMobileTrackingEvent.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import <Foundation/Foundation.h>

@class PHGMobileTrackingSale;

/**
 PHGMobileTrackingEvent represents an event tracked by the mobile tracking service.
 
 Examples could include registration, purchases or upgrades.
 */
@interface PHGMobileTrackingEvent : NSObject

/**
 intialize with given tag for event
 @param tag Description of the event.
 @return Event
*/
- (instancetype) initWithEventTag:(NSString*)tag;

/**
 description of the event.
 */
@property(nonatomic, retain) NSString* eventTag;

/**
 add arbitrary data to an event.  An example of this might be a username associated with a registration event.
 @param key identifier for the data
 @param value data to associate with the event.
 @warning please note this data will be encoded in transit using the objects [description].
 */
- (void) addEventInformationWithKey:(NSString*)key andValue:(NSString*)value;

/**
 add sale (PHG usually terms this a conversion item) to an event.
 @param sale A sale
 @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place.
 */
- (void) addSale:(PHGMobileTrackingSale*)sale ofCurrency:(NSString*)currencyCode;


/**
 add array of sales to an event.
 @param sales NSArray of sales
 @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place.
 */
- (void) addSales:(NSArray*)sales ofCurrency:(NSString*)currencyCode;




@end
