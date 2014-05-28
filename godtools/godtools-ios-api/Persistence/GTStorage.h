//
//  GTStorage.h
//  godtools
//
//  Created by Michael Harrison on 3/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "CRUStorage.h"
#import "GTStorageErrorHandler.h"

/**
 *  Core Data Stack configured for God Tools.
 *  Subclass of CRUStorage, a Core Data stack designed for normal use an background importing.
 */
@interface GTStorage : CRUStorage

/**
 *  Singleton of GTStorage.
 *
 *  @return Configured Singleton
 */
+ (instancetype)sharedStorage;

/**
 *  Initializer that configures the Storage stack based on method parameters.
 *
 *  @param storeURL     URL of sqlite file. Usually you put it in the Application Documents folder. This method will create it if it doesn't exist.
 *  @param modelURL     URL of managed object model file. Usually apart of the main bundle.
 *  @param shared       determines whether each context gets its own store coordinator or whether they share a store coordinator. Refer to CRUStorage initalizer for more details
 *  @param errorHandler Error handler, used by class to display errors that occur in its use.
 *
 *  @return configured storage object
 */
- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL contextsSharePersistentStoreCoordinator:(BOOL)shared errorHandler:(GTStorageErrorHandler *)errorHandler;

/**
 *  Error handler, used by class to display errors that occur in its use.
 */
@property (nonatomic, strong, readonly) GTStorageErrorHandler *errorHandler;

@end
