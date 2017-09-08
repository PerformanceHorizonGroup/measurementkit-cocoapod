//
//  PHGMobileTrackingEvent+Internals.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

@class PHNSale;


#ifndef PHNEvent_Internals_h
#define PHNEvent_Internals_h

NS_ASSUME_NONNULL_BEGIN

@interface PHNEvent(Internals)

@property(nonatomic) NSDate* createdAt;
@property(nonatomic) NSString* _Nullable salesCurrency;
@property(nonatomic) NSArray<PHNSale*>* sales;
@property(nonatomic) NSMutableDictionary<NSString*, NSString*>* metaItems;

@end;

NS_ASSUME_NONNULL_END

#endif//;
