//
//  PHNSimpleStore.m
//  PHGMobileTracking
//
//  Created by Owain Brown on 02/11/2015.
//
//

#import "PHNSimpleStore.h"
#import <UIKit/UIKit.h>
#import "PHNExecutor.h"

@interface PHNSimpleStore()

@property(nonatomic, readonly) NSFileManager* manager;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, id<PHNSimplyStoreable>>* registeredList;
@property(nonatomic, retain) PHNExecutor* executor;

@end


@implementation PHNSimpleStore

- (instancetype) initWithFileManager:(NSFileManager*)filemanager
                   andRegisteredList:(NSMutableDictionary*)registeredList
{
    if (self = [super init]) {
        _manager = filemanager;
        _registeredList = registeredList;
        _executor = [[PHNExecutor alloc] init];
        
        PHNSimpleStore* __weak weakself = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            
            [weakself.executor execute:^{
                [weakself writeAllToDisk];
            }];
            
        }];
    }
    
    return self;
}

- (instancetype) init
{
    self = [self initWithFileManager:[NSFileManager defaultManager] andRegisteredList:[NSMutableDictionary dictionary]];
    
    return self;
}

- (BOOL) register:(id<PHNSimplyStoreable>)storable withPath:(NSString *)path {

    self.registeredList[path] = storable;
    
    NSURL* filepath = [self storedFilePathWithFileName:path];
    
    [self.executor execute:^{
        
        //guard for invalid urls.
        if (!filepath) {
            return;
        }
        
        NSDictionary* storedobject = [self readFromDisk:filepath];
        
        if (storedobject) {
            [self.registeredList[path] updateWithStorageForm:storedobject];
        }
    }];
    
    return YES;
}

- (void) setOpQueue:(NSOperationQueue *)opQueue {
    self.executor = [[PHNExecutor alloc] initWithOperationQueue:opQueue];
}

- (NSOperationQueue*) opQueue {
    return self.executor.operationQueue;
}

#pragma mark private functions

            
- (NSURL*) storedFilePathWithFileName:(NSString*)path {
    
    return [[[self.manager URLForDirectory:NSCachesDirectory
                                         inDomain:NSUserDomainMask
                                appropriateForURL:nil
                                           create:NO
                                            error:nil]
             URLByAppendingPathComponent:@"com.performancehorizon.phnmmk/"]
            URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.cache", path]];
}

- (void) writeAllToDisk {
    for (NSString* path in self.registeredList){
        
        NSURL* filepath  = [self storedFilePathWithFileName:path];
        NSDictionary* storable = [self.registeredList[path] storageForm];
        
        //guard for invalid urls.
        if (filepath && storable){
            [self writeToDisk:filepath storable:storable];
        }
    }
}

- (void) writeToDisk:(NSURL*)path storable:(NSDictionary*)storable{
    
    NSURL* directory = [path URLByDeletingLastPathComponent];
    
    //ensure the directory is present
    [self.manager createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSData* contents = [NSKeyedArchiver archivedDataWithRootObject:storable];
    
    //can write if unlocked, can't read.
    [self.manager createFileAtPath:path.path contents:contents attributes:@{NSFileProtectionKey:NSFileProtectionCompleteUnlessOpen}];
}

- (NSDictionary*) readFromDisk:(NSURL*) path {
    
    NSData* contents= [self.manager contentsAtPath:path.path];

    if (contents) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:contents];
    }
    else {
        return nil;
    }
}

@end
