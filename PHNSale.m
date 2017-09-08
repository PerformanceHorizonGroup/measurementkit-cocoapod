//
//  PHNSale.m
//  PHNMeasurementKit
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import "PHNSale.h"


@interface PHNSale() <NSCoding>

- (BOOL) isEqualToSale:(PHNSale*)sale;

@property(nonatomic, retain) NSMutableDictionary <NSString*, NSString*>* saleMeta;


@end

@implementation PHNSale

- (instancetype) initWithCategory:(NSString*)category andValue:(NSDecimalNumber*)value
{
    if (self = [super init]) {
        _category = category;
        _value = value;
        _saleMeta = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (instancetype) saleWithCategory:(NSString*)category andValue:(NSDecimalNumber*)value
{
    return [[PHNSale alloc] initWithCategory:category andValue:value];
}

+ (instancetype) saleWithCategory:(NSString*)category value:(NSDecimalNumber*)value sku:(NSString*)sku andQuantity:(NSInteger)quantity
{
    PHNSale* sale = [PHNSale saleWithCategory:category andValue:value];
    sale.sku = sku;
    sale.quantity = @(quantity);
    
    return sale;
}

#pragma mark - NSCoding

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.category forKey:@"category"];
    [aCoder encodeObject:self.value forKey:@"value"];
    
    if (self.quantity) {
        [aCoder encodeObject:self.quantity forKey:@"quantity"];
    }
    
    if (self.sku) {
        [aCoder encodeObject:self.sku forKey:@"sku"];
    }
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {

    if (self = [self initWithCategory:[aDecoder decodeObjectForKey:@"category"]
                             andValue:[aDecoder decodeObjectForKey:@"value"]]) {
    
        _quantity = [aDecoder decodeObjectForKey:@"quantity"];
        _sku = [aDecoder decodeObjectForKey:@"sku"];
    }
    
    return self;
}

#pragma mark - Equality

- (BOOL) isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[PHNSale class]]) {
        return NO;
    }
    else {
        return [self isEqualToSale:(PHNSale*)object];
    }
    
}

- (NSUInteger) hash {
    return [self.category hash] ^ [self.value hash] ^ [self.quantity hash] ^ [self.sku hash] ^ [self.saleMeta hash];
}


- (BOOL) isEqualToSale:(PHNSale*)sale {
    
    return [self.category isEqualToString: sale.category] &&
        [self.value isEqualToNumber:sale.value] &&
        ((sale.sku || self.sku) ? [self.sku isEqualToString:sale.sku] : YES) &&
        ((sale.quantity || self.quantity) ? [self.quantity isEqualToNumber:sale.quantity] : YES) &&
        [sale.saleMeta isEqualToDictionary:self.saleMeta];
}

- (void) setMetaItemWithKey:(NSString*)key andValue:(NSString*)value {
    //guard for invalid values
    if (!key || !value)
        return;
    
    self.saleMeta[key] = value;
}

@end


