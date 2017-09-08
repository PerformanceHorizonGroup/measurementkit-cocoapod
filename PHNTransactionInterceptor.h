//
//  PHNTransactionWrapper.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 23/11/2015.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class PHNMeasurementService;

/**
 @class PHNTransactionInterceptor
 @abstract Automatically generates and submits PHNEvent objects while wrapping a SKPaymentTransactionObserver.
 @discussion will forward all SKPaymentTransactionObserver onto the observer provided on init. Purchases
 will generate PHNEvents which will be submitted to the provided measurement service.
 
 */
@interface PHNTransactionInterceptor : NSObject<SKPaymentTransactionObserver>

- (instancetype) initWithTransactionObserver:(id<SKPaymentTransactionObserver>)wrappedObserver
                       andMeasurementService:(PHNMeasurementService *)measurementService;

///@property observer - all SKPaymentTransactionObserver calls will be forwarded to this object
@property(nonatomic, strong) id<SKPaymentTransactionObserver> observer;

/**
 registers a product so that PHNEvents can be automatically be generated from purchases
 of that product
 @param product - the product details for use in generating PHNEvents for purchases.
 */
- (void) registerProduct:(SKProduct *)product;

@end
