//
//  PHGActiveFingerPrinter.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 25/02/2015.
//
//

#import <Foundation/Foundation.h>

@class PHNHostHelper;

@protocol PHNActiveFingerprinterDelegate <NSObject>

- (void) activeFingerprinterDidCompleteWithResults:(NSDictionary*)dictionary;

@end

@interface PHNActiveFingerprinter : NSObject

- (instancetype) initWithHostHelper:(PHNHostHelper*)helper;

- (void) fingerprintWithIDFA:(NSString*)idfa;
- (void) fingerprintWithUUID:(NSString*)uuid;

- (void) fingerprint;

- (void) clearCompleted;

@property(nonatomic, weak) id<PHNActiveFingerprinterDelegate> delegate;

@property(nonatomic, assign) BOOL fingerprintComplete;
@property(nonatomic, assign) BOOL fingerprintInProgress;


@end
