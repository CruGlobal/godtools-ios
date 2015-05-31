//
//  GTStorage.m
//  godtools
//
//  Created by Michael Harrison on 3/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTStorage.h"

NSString *const GTStorageSqliteDatabaseFilename = @"godtools.sqlite";
NSString *const GTStorageModelName				= @"GTModel";

@interface GTStorage ()



@end

@implementation GTStorage

+ (instancetype)sharedStorage {
	
	static GTStorage *_sharedStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		
        _sharedStorage = [[GTStorage alloc] initWithStoreURL:[GTStorage storeURL]
												   storeType:NSSQLiteStoreType
													modelURL:[GTStorage modelURL]
					 contextsSharePersistentStoreCoordinator:YES
												errorHandler:[GTStorageErrorHandler sharedErrorHandler]];
		
		_sharedStorage.mainObjectContext.undoManager	= nil;
		
    });
    
    return _sharedStorage;
	
}

- (id)initWithStoreURL:(NSURL*)storeURL storeType:(NSString *)storeType modelURL:(NSURL*)modelURL contextsSharePersistentStoreCoordinator:(BOOL)shared errorHandler:(GTStorageErrorHandler *)errorHandler {
	
	@try {
		
		self = [super initWithStoreURL:storeURL storeType:storeType modelURL:modelURL contextsSharePersistentStoreCoordinator:shared];
		
		if (self) {
			
			_errorHandler = errorHandler;
			
		}
		
		return self;
		
	}
	@catch (NSException *exception) {
		
		[errorHandler displayError:exception.userInfo[CRUStorageExceptionUserInfoKeyForError]];
		
	}
	
}

+ (NSURL *)storeURL {
	
    NSURL* documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
												   inDomain:NSUserDomainMask
										  appropriateForURL:nil
													 create:YES
													  error:nil];
	
	return [documentsDirectory URLByAppendingPathComponent:GTStorageSqliteDatabaseFilename];
}

+ (NSURL *)modelURL {
	
	return [[NSBundle mainBundle] URLForResource:GTStorageModelName withExtension:@"momd"];
	
}

- (NSArray *)fetchArrayOfModels:(Class)modelType inBackground:(BOOL)background {
    
    if (modelType == nil) {
        return nil;
    }
    
    NSManagedObjectContext *context	= ( background ? self.backgroundObjectContext : self.mainObjectContext );
    NSEntityDescription *entity		= [NSEntityDescription entityForName:NSStringFromClass(modelType)
                                               inManagedObjectContext:context];
    //NSLog(@"ENTITY; %@",entity);
    //NSLog(@"value: %@",valueArray);
    
    NSFetchRequest *fetchRequest	= [[NSFetchRequest alloc] init];
    fetchRequest.entity				= entity;
    
    NSArray *fetchedObjects			= [context executeFetchRequest:fetchRequest error:nil];
    
    //NSLog(@"fetched array: %@",fetchedObjects);
    
    return fetchedObjects;
}


- (NSArray *)fetchModel:(Class)modelType usingKey:(NSString *)key forValue:(NSString *)value inBackground:(BOOL)background {
    
    if (modelType == nil || key == nil || value == nil) {
        return nil;
    }
    
    NSManagedObjectContext *context	= ( background ? self.backgroundObjectContext : self.mainObjectContext );
    NSEntityDescription *entity		= [NSEntityDescription entityForName:NSStringFromClass(modelType)
                                               inManagedObjectContext:context];
    //NSLog(@"ENTITY; %@",entity);
    //NSLog(@"value: %@",valueArray);
    
    NSFetchRequest *fetchRequest	= [[NSFetchRequest alloc] init];
    fetchRequest.entity				= entity;
    fetchRequest.predicate			= [NSPredicate predicateWithFormat:@"%K == %@", key, value];
    
    NSArray *fetchedObjects			= [context executeFetchRequest:fetchRequest error:nil];
    
    //NSLog(@"fetched array: %@",fetchedObjects);
    
    return fetchedObjects;
}

@end