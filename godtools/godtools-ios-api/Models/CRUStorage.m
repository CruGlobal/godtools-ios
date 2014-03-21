//
//  CRUStorage.m
//  godtools
//
//  Created by Michael Harrison on 3/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "CRUStorage.h"

NSString *const CRUStorageExceptionNameForCouldNotOpenStore	= @"org.cru.crustorage.exception.name.couldnotopenstore";

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

- (void)setupManagedObjectContexts {
	
	self.mainObjectContext				= [self managedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
	self.mainObjectContext.undoManager	= [[NSUndoManager alloc] init];
	
	self.backgroundObjectContext		= [self managedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
	self.backgroundObjectContext.undoManager = nil;
	
	//merge changes from background context to main context once background saves.
	__weak typeof(self)weakSelf = self;
	[[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
													  object:nil
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

- (NSManagedObjectModel*)managedObjectModel {
	
	return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}

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
										 userInfo:nil];
		}
	}
	
}

@end
