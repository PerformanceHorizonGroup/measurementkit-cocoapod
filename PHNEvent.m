//
//  PHGMobileTrackingEvent.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import "PHNEvent.h"
#import "PHNSale.h"

@interface PHNEvent() <NSCoding>
    @property(nonatomic) NSDate* createdAt;
    @property(retain) NSString* _Nullable salesCurrency;
    @property(nonatomic) NSArray<PHNSale*>* sales;
    @property(nonatomic) NSString* eventId;
    @property(nonatomic) NSMutableDictionary<NSString*, NSString*>* metaItems;

    - (BOOL) isEqualToEvent:(PHNEvent*)event;

    /**
     add sale (PH usually terms this a conversion item) to an event.
     @param sale A sale
     @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place.
     @warning will overwrite any currently attached sales, if present.
     */
    - (void) addSale:(PHNSale*)sale ofCurrency:(NSString*)currencyCode;

    /**
     add array of sales to an event.
     @param sales NSArray of sales (PHNSale)
     @param currencyCode ISO-4217 (3-letter) currency code in which the sale takes place.
     @warning will overwrite any currently attached sales, if present.
     */
    - (void) addSales:(NSArray*)sales ofCurrency:(NSString*)currencyCode;
@end;

@implementation PHNEvent

#pragma mark - initializers and convenience initializers
- (instancetype) init {
    
    self = [self initWithEventId:[NSUUID UUID].UUIDString andDateCreated:[NSDate date]];
    return self;
}


- (instancetype) initWithEventId:(NSString*)eventID andDateCreated:(NSDate*)date  {
    
    if (self = [super init]) {
        _eventId = eventID;
        _createdAt = date;
        
        self.sales = [NSArray array];
        self.metaItems = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (instancetype) initWithCategory:(NSString*)category
{
    if (self = [self init]) {
        _sales = @[[PHNSale saleWithCategory:category andValue:[NSDecimalNumber decimalNumberWithString:@"0.0"]]];
    }
    return self;
}

- (instancetype) initWithSale:(PHNSale*)sale ofCurrency:(NSString*)currencyCode
{
    if (self = [self init]) {
        [self addSale:sale ofCurrency:currencyCode];
    }
    
    return self;
}

-(instancetype) initWithEventId:(NSString*)eventID
                    dateCreated:(NSDate*)date
                          sales:(NSArray*)sales
                     ofCurrency:(NSString*)currency {
    
    if (self = [self initWithEventId:eventID andDateCreated:date]) {
        [self addSales:sales ofCurrency:currency];
    }
    
    return self;
}

- (instancetype) initWithSales:(NSArray*)sales ofCurrency:(NSString*)currencyCode
{
    if (self = [self init]) {
        [self addSales:sales ofCurrency:currencyCode];
    }
    
    return self;
}

+ (instancetype) eventWithCategory:(NSString*)category
{
    return [[self alloc] initWithCategory:category];
}

+ (instancetype) eventWithSale:(PHNSale*)sale ofCurrency:(NSString*)currencyCode
{
    return [[self alloc] initWithSale:sale ofCurrency:currencyCode];
}

+ (instancetype) eventWithSales:(NSArray*)sales ofCurrency:(NSString*)currencyCode
{
    return [[self alloc] initWithSales:sales ofCurrency:currencyCode];
}

#pragma mark - public methods

- (void) addSales:(NSArray*)sales ofCurrency:(NSString*)currencyCode;
{
    self.sales = sales;
    self.salesCurrency = currencyCode;
}

- (void) addSale:(PHNSale*)sale ofCurrency:(NSString*)currencyCode
{
    [self addSales:[NSArray arrayWithObject:sale] ofCurrency:currencyCode];
}

- (NSString*) category
{
    if (self.sales.count != 1)
        return nil;
    else {
        return self.sales[0].category;
    }
}

- (void) setMetaItemWithKey:(NSString*)key andValue:(NSString*)value {
    if (!key || !value)
        return;
    
    self.metaItems[key] = value;
}

#pragma mark - NSCoding

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.sales forKey:@"sales"];
    [aCoder encodeObject:self.createdAt forKey:@"eventDate"];
    [aCoder encodeObject:self.metaItems forKey:@"eventMeta"];
    [aCoder encodeObject:self.eventId forKey:@"eventIdentifier"];
    
    if (self.salesCurrency) {
        [aCoder encodeObject:self.salesCurrency forKey:@"saleCurrency"];
    }
    
    if (self.voucher) {
        [aCoder encodeObject:self.salesCurrency forKey:@"eventVoucher"];
    }
    
    if (self.conversionReference) {
        [aCoder encodeObject:self.conversionReference forKey:@"eventConvref"];
    }
    
    if (self.customerReference) {
        [aCoder encodeObject:self.customerReference forKey:@"eventCustref"];
    }
    
    if (self.country) {
        [aCoder encodeObject:self.country forKey:@"eventCountry"];
    }
    
    if (self.customerType) {
        [aCoder encodeObject:self.customerType forKey:@"eventCustomerType"];
    }
}

- (instancetype) initWithCoder:(NSCoder*)aDecoder
{
    if ([self initWithEventId:[aDecoder decodeObjectForKey:@"eventIdentifier"]
                  dateCreated:[aDecoder decodeObjectForKey:@"eventDate"]
                        sales:[aDecoder decodeObjectForKey:@"sales"]
                   ofCurrency:[aDecoder decodeObjectForKey:@"saleCurrency"]]) {
        
        _voucher = [aDecoder decodeObjectForKey:@"eventVoucher"];
        _conversionReference = [aDecoder decodeObjectForKey:@"eventConvref"];
        _customerReference = [aDecoder decodeObjectForKey:@"eventCustref"];
        _country = [aDecoder decodeObjectForKey:@"eventCountry"];
        _customerType = [aDecoder decodeObjectForKey:@"eventCustomerType"];
        _metaItems = [aDecoder decodeObjectForKey:@"eventMeta"];
    }

    return self;
}

#pragma mark - Equality

- (BOOL) isEqual:(id)object
{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[PHNEvent class]]) {
        return NO;
    }
    else {
        return [self isEqualToEvent:(PHNEvent*)object];
    }
}

- (BOOL) isEqualToEvent:(PHNEvent*)event
{
    return [event.eventId isEqualToString:self.eventId];
}

- (NSUInteger) hash
{
    return [self.eventId hash];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"event with %tu sales", self.sales.count];
}

@end
