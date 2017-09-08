//
//  PHNTransactionWrapper.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 23/11/2015.
//
//

#import "PHNTransactionInterceptor.h"
#import "PHNMeasurementService.h"

#import "PHNEvent.h"
#import "PHNEvent+StoreKit.h"
#import "PHNSale.h"

@interface PHNTransactionInterceptor ()

@property(nonatomic, strong) PHNMeasurementService *measurementService;
@property(nonatomic, strong) NSMutableDictionary<NSString *, SKProduct *> *products;

@end

@implementation PHNTransactionInterceptor

- (instancetype) initWithTransactionObserver:(id<SKPaymentTransactionObserver>)wrappedObserver
                       andMeasurementService:(PHNMeasurementService*)measurementService {
    
    if (self = [super init]) {
        _observer = wrappedObserver;
        _measurementService = measurementService;
        _products = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void) registerProduct:(SKProduct *)product {
    self.products[product.productIdentifier] = product;
}

#pragma mark - SKPaymentTransactionObserver

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    //filter to purchases, where the product has been registered.
    for (SKPaymentTransaction *transaction in [transactions filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        SKPaymentTransaction *transaction = (SKPaymentTransaction *) evaluatedObject;
        
        return (transaction.transactionState == SKPaymentTransactionStatePurchased) &&
        self.products[transaction.payment.productIdentifier];
    }]]) {
        
        //generate event, track.
        [self.measurementService trackEvent:[PHNEvent eventWithProduct:self.products[transaction.payment.productIdentifier]
                                                           andQuantity:transaction.payment.quantity]];

    }
    
    //proxy
    if ([self.observer respondsToSelector:@selector(paymentQueue:updatedTransactions:)]) {
        [self.observer paymentQueue:queue updatedTransactions:transactions];
    }
}

- (void) paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    if ([self.observer respondsToSelector:@selector(paymentQueue:removedTransactions:)]) {
        [self.observer paymentQueue:queue removedTransactions:transactions];
    }
}

- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if ([self.observer respondsToSelector:@selector(paymentQueue:restoreCompletedTransactionsFailedWithError:)]) {
        [self.observer paymentQueue:queue restoreCompletedTransactionsFailedWithError:error];
    }
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if ([self.observer respondsToSelector:@selector(paymentQueueRestoreCompletedTransactionsFinished:)]) {
        [self.observer paymentQueueRestoreCompletedTransactionsFinished:queue];
    }
}

- (void) paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads {
    if ([self.observer respondsToSelector:@selector(paymentQueue:updatedDownloads:)]) {
        [self.observer paymentQueue:queue updatedDownloads:downloads];
    }
}

@end
