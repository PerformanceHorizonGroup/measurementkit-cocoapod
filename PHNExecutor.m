//
//  PHNExecutor.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 03/11/2015.
//
//

#import "PHNExecutor.h"

@interface PHNExecutor()

@end

@implementation PHNExecutor

- (instancetype) initWithOperationQueue:(NSOperationQueue*)operationQueue {
    
    if (self = [super init]) {
        _operationQueue = operationQueue;
    }
    
    return self;
}

+ (instancetype) executorWithOperationQueue:(NSOperationQueue*)queue
{
    return [[PHNExecutor alloc ] initWithOperationQueue:queue];
}

- (void) execute:(void (^)())block {
    if (self.operationQueue) {
        [self.operationQueue addOperationWithBlock:block];
    }
    else {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), block);
    }
}

- (void) execute:(void (^)())block withDelay:(double)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self execute:block];
    });
}

- (NSInteger) maxConcurrentOperationCount {
    return self.operationQueue ?  self.operationQueue.maxConcurrentOperationCount : 1;
}

@end
