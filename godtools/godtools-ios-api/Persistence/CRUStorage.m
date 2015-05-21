//
//  CRUStorage.m
//  godtools
//
//  Created by Michael Harrison on 3/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "CRUStorage.h"

NSString *const CRUStorageExceptionNameForCouldNotOpenStore	= @"org.cru.crustorage.exception.name.couldnotopenstore";
NSString *const CRUStorageExceptionUserInfoKeyForError		= @"org.cru.crustorage.exception.userInfo.key.error";

@interface CRUStorage ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext* mainObjectContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext* backgroundObjectContext;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *sharedPersistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSURL* modelURL;
@property (nonatomic, strong) NSURL* storeURL;
@property (nonatomic, assign) BOOL contextsShareStoreCoordinator;

- (void)setupManagedObjectContexts;
- (NSManagedObjectContext *)managedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;
- (NSPersistentStoreCoordinator *)newPersistentStoreCoordinator;
- (void)recoverFromError:(NSError *)error forPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)storeCoordinator;

@end

@implementation CRUStorage

@synthesize sharedPersistentStoreCoordinator	= _sharedPersistentStoreCoordinator;

#pragma mark - Initialization

- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL contextsSharePersistentStoreCoordinator:(BOOL)shared {
	
	self = [super init];
	
	if (self) {
		
		self.storeURL						= storeURL;
		self.modelURL						= modelURL;
		self.contextsShareStoreCoordinator	= shared;
		[self setupManagedObjectContexts];
		
	}
	
	return self;
}

#pragma mark - Managed Object Context Creation

- (void)setupManagedObjectContexts {
	
	self.mainObjectContext				= [self managedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
	self.mainObjectContext.undoManager	= [[NSUndoManager alloc] init];
	
	self.backgroundObjectContext		= [self managedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
	self.backgroundObjectContext.undoManager = nil;
	
	//merge changes from background context to main context once background saves.
	__weak typeof(self)weakSelf = self;
	[[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
													  object:self.backgroundObjectContext
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
												  
													  NSManagedObjectContext *mainObjectContext = weakSelf.mainObjectContext;
													  
													  if (notification.object != mainObjectContext) {
														  
														  [mainObjectContext performBlock:^(){
															  [mainObjectContext mergeChangesFromContextDidSaveNotification:notification];
														  }];
														  
													  }
													  
												  }];
	
}

- (NSManagedObjectContext *)managedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
	
	NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
	
	if (self.contextsShareStoreCoordinator) {
		managedObjectContext.persistentStoreCoordinator = self.sharedPersistentStoreCoordinator;
	} else {
		managedObjectContext.persistentStoreCoordinator = [self newPersistentStoreCoordinator];
	}
	
	return managedObjectContext;
}

#pragma mark - Object Model Creation

- (NSManagedObjectModel*)managedObjectModel {
	
	return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}

#pragma mark - Persistent Store Creation

- (NSPersistentStoreCoordinator *)sharedPersistentStoreCoordinator {
	
	if (!_sharedPersistentStoreCoordinator) {
		
		_sharedPersistentStoreCoordinator = [self newPersistentStoreCoordinator];
		
	}
	
	return _sharedPersistentStoreCoordinator;
}

- (NSPersistentStoreCoordinator *)newPersistentStoreCoordinator {
	
	NSPersistentStoreCoordinator *newPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	NSError* error;
	[newPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
												configuration:nil
														  URL:self.storeURL
													  options:@{NSMigratePersistentStoresAutomaticallyOption:	@YES,
																NSInferMappingModelAutomaticallyOption:			@YES}
														error:&error];
	if (error) {
		[self recoverFromError:error forPersistentStoreCoordinator:newPersistentStoreCoordinator];
	}
	
	return newPersistentStoreCoordinator;
}

- (void)recoverFromError:(NSError *)error forPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)storeCoordinator {
	
	if (error) {
		
		[[NSFileManager defaultManager] removeItemAtURL:self.storeURL error:nil];
		error = nil;
		
		[storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
									   configuration:nil
												 URL:self.storeURL
											 options:@{NSMigratePersistentStoresAutomaticallyOption:	@YES,
													   NSInferMappingModelAutomaticallyOption:			@YES}
											   error:&error];
		
		if (error) {
			@throw [NSException exceptionWithName:CRUStorageExceptionNameForCouldNotOpenStore
										   reason:error.localizedDescription
										 userInfo:@{CRUStorageExceptionUserInfoKeyForError: error}];
		}
	}
	
}

#pragma mark - FetchRequests

- (NSArray *)fetchArrayOfModels:(Class)modelType usingKey:(NSString *)key forValues:(NSArray *)valueArray inBackground:(BOOL)background {
	
	if (modelType == nil || key == nil || valueArray == nil) {
		return nil;
	}
	
	NSManagedObjectContext *context	= ( background ? self.backgroundObjectContext : self.mainObjectContext );
	NSEntityDescription *entity		= [NSEntityDescription entityForName:NSStringFromClass(modelType)
											  inManagedObjectContext:context];
    //NSLog(@"ENTITY; %@",entity);
    //NSLog(@"value: %@",valueArray);
    
	NSFetchRequest *fetchRequest	= [[NSFetchRequest alloc] init];
	fetchRequest.entity				= entity;
	fetchRequest.predicate			= [NSPredicate predicateWithFormat:@"%K IN %@", key, valueArray];
	
	NSArray *fetchedObjects			= [context executeFetchRequest:fetchRequest error:nil];
    
    //NSLog(@"fetched array: %@",fetchedObjects);
	
	return fetchedObjects;
}

@end
