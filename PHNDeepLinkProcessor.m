//
//  PHNDeepLinkProcessor.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 09/11/2015.
//
//

#import "PHNDeepLinkProcessor.h"

@implementation PHNDeepLinkProcessor


- (instancetype) init {
    if (self= [super init]) {
        _processedCamref = nil;
        _processedTrackingID = nil;
    }
    
    return self;
}

- (NSURL*) processsURL:(NSURL*)url {
    //since the results are so simple, easier to leave them as side effects.
    //but they need to be cleared on each process call. (oh swift and enumerated types)
    _processedCamref = nil;
    _processedTrackingID = nil;
    
    NSURLComponents* components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    NSArray* queryitems = [components queryItems] ?: [NSArray array];
    
    NSMutableArray<NSURLQueryItem*>* filteredqueryitems = [NSMutableArray arrayWithArray:queryitems];
    
    NSUInteger trackingidindex = [queryitems indexOfObjectPassingTest:^BOOL(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.name isEqualToString:@"phn_mtid"];
    }];
    
    if (trackingidindex != NSNotFound) {
        
        _processedTrackingID = ((NSURLQueryItem*)queryitems[trackingidindex]).value;
        
        //remove the query items.
        [filteredqueryitems removeObjectAtIndex:trackingidindex];
    }
    
    NSUInteger camrefindex = [queryitems indexOfObjectPassingTest:^BOOL(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.name isEqualToString:@"phn_camref"];
    }];
    
    if (camrefindex != NSNotFound) {
        
        _processedCamref = ((NSURLQueryItem*)queryitems[camrefindex]).value;
        
        //remove the query items.
        [filteredqueryitems removeObjectAtIndex:camrefindex];
    }
    
    //third party universal
    NSUInteger universalcamrefindex = [queryitems indexOfObjectPassingTest:^BOOL(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.name isEqualToString:@"camref"];
    }];
    
    if (universalcamrefindex != NSNotFound) {
        
        _processedCamref = ((NSURLQueryItem*)queryitems[universalcamrefindex]).value;
        
        //remove the query items.
        [filteredqueryitems removeObjectAtIndex:universalcamrefindex];
    }
    
    //phg universal
    if ([components.host isEqualToString:@"m.prf.hn"]) {
        
        //separate out into a path variables array
        NSArray<NSString*>* pathcomponents =  [components.path componentsSeparatedByString:@"/"];
        
        NSMutableDictionary<NSString*, NSString*>* pathvariables = [NSMutableDictionary dictionary];
        
        for (NSString* pathcomponent in pathcomponents) {
            NSArray<NSString*>* seperatedcomponent = [pathcomponent componentsSeparatedByString:@":"];
            
            if ([seperatedcomponent count] > 1) {
                pathvariables[seperatedcomponent[0]] = seperatedcomponent[1];
            }
        }
        
        if (pathvariables[@"mscheme"] && pathvariables[@"camref"]) {
            _processedCamref = pathvariables[@"camref"];
            
            NSString * returnedurl = [NSString stringWithFormat:@"%@://", pathvariables[@"mscheme"]];
            
            if (pathvariables[@"mpath"]) {
                returnedurl = [returnedurl stringByAppendingString:[pathvariables[@"mpath"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        
            return [NSURL URLWithString:returnedurl];
        }
    }
    
    components.queryItems = filteredqueryitems;
    
    //remove the ?
    if (components.queryItems.count == 0) {
        components.queryItems = nil;
    }
    
    return [components URL];
}




@end
