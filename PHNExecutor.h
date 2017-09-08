//
//  PHNExecutor.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 03/11/2015.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Wrapper for simple block-based execution.  Works with an opqueue, or just falls back to
 * the GCD dispatch queue.
 */
@interface PHNExecutor : NSObject

- (instancetype) initWithOperationQueue:(NSOperationQueue*)operationQueue;
+ (instancetype) executorWithOperationQueue:(NSOperationQueue*)queue;

/**
 * Run the block immediately in the background.
 * @param block - block to be executed.
 */
- (void) execute:(void (^)())block;

- (void) execute:(void (^)())block withDelay:(double)delay;

///Operation queue backing the executor.
@property(nonatomic, readonly) NSOperationQueue* _Nullable operationQueue;

//maximum concurrent execution count of the executor.
- (NSInteger) maxConcurrentOperationCount;

@end





NS_ASSUME_NONNULL_END