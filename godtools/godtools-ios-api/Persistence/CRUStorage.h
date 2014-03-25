//
//  CRUStorage.h
//  godtools
//
//  Created by Michael Harrison on 3/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const CRUStorageExceptionNameForCouldNotOpenStore;
extern NSString *const CRUStorageExceptionUserInfoKeyForError;

@interface CRUStorage : NSObject

/**
 @param storeURL - URL of sqlite file. Usually you put it in the Application Documents folder.
 This method will create it if it doesn't exist.
 @param modelURL - URL of managed object model file. Usually apart of the main bundle.
 @param shared - determines whether each context gets its own store coordinator or whether they share a store coordinator. Sharing a store coordinator means a shared cache but more locking so is good for cases where there are fewer writes. Separate store coordinators mean less locking but no shared cache so is good for cases with lots of changes. Refer to http://www.objc.io/issue-10/networked-core-data-application.html
 
 @warning If there is an issue with opening the persistent store an exception will be thrown with name set to  CRUStorageExceptionNameForCouldNotOpenStore
 */
- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL contextsSharePersistentStoreCoordinator:(BOOL)shared;

/**
 The context that works on the main thread. This should be used for fetch request that update the UI. If you are updating the database with a bunch of data at a time then use the background context.
 */
@property (nonatomic,readonly) NSManagedObjectContext* mainObjectContext;

/**
 Anything put into the background context will automatically be merged into the main context once the background context is saved. So please save batches of data (especially from web services) to this context and do your fetch requests on the main context.
 */
@property (nonatomic,readonly) NSManagedObjectContext* backgroundObjectContext;

/**
 Will grab an array of Model Objects from the Persistent Store where their value for key matches one of the IDs in IDsArray
 @param modelType - Class of object you want to grab (assumes Class name matches CoreData Entity name)
 @param key - The name of the instance variable on the Model that you would like to search. It will return models with IDs that match the value on myModel.myKey in IDsArray[]
 @param valueArray - array of IDs that you would like to search for.
 @param background - should it be run on the background context (using its background queue) or the main context (using the main thread)
 @example [myStorage fetchArrayOfModels:[Book class] usingKey:@"title" forIDs:@[@"Gone with the wind", @"The Bible"] inBackground:YES];
 this would search in the background for books with the title "Gone with the wind" or "The Bible".
 */
- (NSArray *)fetchArrayOfModels:(Class)modelType usingKey:(NSString *)key forValues:(NSArray *)valueArray inBackground:(BOOL)background;

@end
