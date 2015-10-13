//
//  CRUStorage.h
//  godtools
//
//  Created by Michael Harrison on 3/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 *  Name of notification that is fired when database is corrupted and a fresh database is created to recover from the error.
 *  Note: It will only be fired if the recovery is successful. If a new database could not be created the CRUStorageExceptionNameForCouldNotOpenStore
 *  exception will be fired.
 */
extern NSString *const CRUStorageNotificationRecoveryCompleted;

/**
 *  Name for 'Could not open persistent store' exception.
 */
extern NSString *const CRUStorageExceptionNameForCouldNotOpenStore;
/**
 *  Key for UserInfo that accompanies exceptions from this class.
 */
extern NSString *const CRUStorageExceptionUserInfoKeyForError;

/**
 *  Core Data stack. Based on http://www.objc.io/issue-10/networked-core-data-application.html
 *  This Class will quickly setup a main object context and a background object context which can either have shared
 *  or separate persistent stores based on how you will use it.
 */
@interface CRUStorage : NSObject

/**
*  Creates and configures Core Data stack based on method parameters.
*
*  @param storeURL URL of sqlite file. Usually you put it in the Application Documents folder. This method will create it if it doesn't exist.
*  @param storeType the type of store that will back this core data stack. The options are the following constants defined in NSPersistentStoreCoordinator: NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType. NSSQLiteStoreType is default.
*  @param modelURL URL of managed object model file. Usually apart of the main bundle.
*  @param shared   determines whether each context gets its own store coordinator or whether they share a store coordinator. Sharing a store coordinator means a shared cache but more locking so is good for cases where there are fewer writes. Separate store coordinators mean less locking but no shared cache so is good for cases with lots of changes. Refer to http://www.objc.io/issue-10/networked-core-data-application.html for more details
*
*  @warning If there is an issue with opening the persistent store an exception will be thrown with name set to  CRUStorageExceptionNameForCouldNotOpenStore
*
*  @return configured storage object
*/
- (id)initWithStoreURL:(NSURL*)storeURL storeType:(NSString *)storeType modelURL:(NSURL*)modelURL contextsSharePersistentStoreCoordinator:(BOOL)shared;

/**
 *  The context that works on the main thread. This should be used for fetch request that update the UI.
 *  If you are updating the database with a bunch of data at a time then use the background context.
 */
@property (nonatomic,readonly) NSManagedObjectContext* mainObjectContext;

/**
 *  The context that works in the background. Good for importing data from a webservice.
 *
 *  @note Anything put into the background context will automatically be merged into the main context once the background context is saved.
 *  So please save batches of data (especially from web services) to this context and do your fetch requests on the main context.
 */
@property (nonatomic,readonly) NSManagedObjectContext* backgroundObjectContext;

/**
 *  Grab an array of Model Objects from the Persistent Store. It will only grab objects where their value for key matches one of the IDs in valueArray
 *
 *  @param modelType  Class of object you want to grab (assumes Class name matches CoreData Entity name)
 *  @param key        The name of the property on the Model that you would like to search. ie is myModel.myKey in valueArray[]
 *  @param valueArray array of values that you would like to search for.
 *  @param background determines if it will be run on the background context (using its background queue) or the main context (using the main thread)
 *
 *  @example [myStorage fetchArrayOfModels:[Book class] usingKey:@"title" forIDs:@[@"Gone with the wind", @"The Bible"] inBackground:YES];
 *  This would search in the background for books with the title "Gone with the wind" or "The Bible".
 *
 *  @return array of models that match the criteria
 */
- (NSArray *)fetchArrayOfModels:(Class)modelType usingKey:(NSString *)key forValues:(NSArray *)valueArray inBackground:(BOOL)background;

@end
