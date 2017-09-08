//
//  PHNEventRequest.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 29/10/2015.
//
//

#import "PHNEventRequest.h"

//request imports
#import "PHNRequestFactory.h"

//events
#import "PHNEvent.h"
#import "PHNEvent+Internals.h"

#import "PHNSale.h"
#import "PHNSale+Internals.h"

@implementation PHNEventRequest

- (instancetype) initWithEvent:(PHNEvent*)event
                    campaignID:(NSString*)campaignID
               andAdvertiserID:(NSString*)advertiserID{

    if (self = [super init]) {
        _event = event;
        _campaignID = campaignID;
        _advertiserID = advertiserID;
    }
    
    return self;
}

- (NSArray<NSDictionary*>*) convertEventSalesToDictionary:(PHNEvent*)event {
    
    NSMutableArray<NSDictionary*>* eventsales = [NSMutableArray array];
    
    for (PHNSale* sale in event.sales) {
        NSMutableDictionary* saleoutput = [NSMutableDictionary dictionaryWithDictionary:@{@"category":sale.category, @"value": [sale.value stringValue]}];
        
        if (sale.sku) {
            saleoutput[@"sku"] = sale.sku;
        }
        
        if (sale.quantity) {
            saleoutput[@"quantity"] = sale.quantity;
        }
        
        if ([sale.saleMeta count] > 0) {
            saleoutput[@"meta"] = sale.saleMeta;
        }
        
        [eventsales addObject:saleoutput];
    }
    
    return eventsales;
}

- (PHNRequest*) requestWithFactory:(PHNRequestFactory*)factory
{
    //guard for event requests where the tracking ID has yet to be set.
    if (!self.trackingID) {
        return nil;
    }
    
    NSArray<NSDictionary*>* sales = [self convertEventSalesToDictionary:self.event];
    
    NSMutableDictionary* requestparameters = [NSMutableDictionary dictionaryWithDictionary:@{@"mobiletracking_id":self.trackingID,
                                 @"campaign_id": self.campaignID,
                                 @"advertiser_id": self.advertiserID,
                                 @"sales": sales,
                                 @"date":@(self.event.createdAt.timeIntervalSince1970)}];
    
    if (self.event.salesCurrency) {
        requestparameters[@"currency"] = self.event.salesCurrency;
    }
    
    if (self.event.country) {
        requestparameters[@"country"] = self.event.country;
    }
    
    if (self.event.voucher) {
        requestparameters[@"voucher"] = self.event.voucher;
    }
    
    if (self.event.conversionReference) {
        requestparameters[@"conversionref"] = self.event.conversionReference;
    }
    
    if (self.event.customerReference) {
        requestparameters[@"custref"] = self.event.customerReference;
    }
    
    if (self.event.customerType) {
        requestparameters[@"customer_type"] = self.event.customerType;
    }
    
    if (self.event.metaItems.count > 0) {
        requestparameters[@"meta"] = self.event.metaItems;
    }
    
    PHNRequest* request = [factory mobileTrackingRequestWithPath:@"/event" andParams:requestparameters];
    
    return request;
}

#pragma mark - NSCoder

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    //definates
    [aCoder encodeObject:self.campaignID forKey:@"campaign_id"];
    [aCoder encodeObject:self.advertiserID forKey:@"advertiser_id"];
    [aCoder encodeObject:self.event forKey:@"event"];
    
    if (self.trackingID) {
        [aCoder encodeObject:self.trackingID forKey:@"tracking_id"];
    }
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [self initWithEvent:[aDecoder decodeObjectForKey:@"event"]
                         campaignID:[aDecoder decodeObjectForKey:@"campaign_id"]
                    andAdvertiserID:[aDecoder decodeObjectForKey:@"advertiser_id"]]) {
        
        _trackingID = [aDecoder decodeObjectForKey:@"tracking_id"];
    }
         
    return self;
}

#pragma mark - Equality

- (BOOL) isEqual:(id)object {
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[PHNEventRequest class]]) {
        return NO;
    }
    else {
        return [self isEqualToEventRequest:(PHNEventRequest*)object];
    }
}

- (BOOL) isEqualToEventRequest:(PHNEventRequest*)eventrequest {
    
    //event may or may not have a tracking id assigned.
    BOOL trackingidcomparison = (self.trackingID || eventrequest.trackingID) ?
        [self.trackingID isEqualToString:eventrequest.trackingID]: YES;
    
    return trackingidcomparison &&
        [self.event isEqual:eventrequest.event] &&
        [self.campaignID isEqualToString:eventrequest.campaignID] &&
        [self.advertiserID isEqualToString:eventrequest.advertiserID];
}

- (NSUInteger) hash {
    
    return [self.trackingID hash] ^ [self.event hash] ^
        [self.campaignID hash] ^ [self.advertiserID hash];
}

@end
