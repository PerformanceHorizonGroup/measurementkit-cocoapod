//
//  PHNSimpleStore.h
//  PHGMobileTracking
//
//  Created by Owain Brown on 02/11/2015.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * protocol for objects that can be written/retrieved from his by PHNSimpleStore.
 */
@protocol PHNSimplyStoreable <NSObject>

/**
 * returns the object represented as a dictionary that can be written to disk.
 * @warning the class must only be composed of objects that can be converted to a plist.
 * @see NSDictionary - writeToFile:atomically:
 */
- (NSDictionary*) storageForm;

/**
 * update storables with their on-disk representation.
 * @param storageForm - dictionary representation of object that has been retrieved from disk.
 * @warning the 
 */
- (void) updateWithStorageForm:(NSDictionary*)storageForm;

@end

/** Simple on-disk store for classes that need to be persistant.  Classes provide a dictionary representation of themselves where they will be written
 to disk.
 */
@interface PHNSimpleStore : NSObject

/**
 * register the object as storable
 *
 * If the application is closed, a representation will be written to disk.
 * On registration, any on-disk representation will be retrieved
 * @param path - the final path component of the on-disk representation.
 */
- (BOOL) register:(id<PHNSimplyStoreable>)storable withPath:(NSString*)path;

//All storage blocks will be run on the opqueue if set, if not they will run on GCD background queue;
@property(nonatomic) NSOperationQueue* _Nullable opQueue;

@end

NS_ASSUME_NONNULL_END