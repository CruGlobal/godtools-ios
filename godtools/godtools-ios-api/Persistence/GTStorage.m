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
													modelURL:[GTStorage modelURL]
					 contextsSharePersistentStoreCoordinator:YES
												errorHandler:[GTStorageErrorHandler sharedErrorHandler]];
		
		_sharedStorage.mainObjectContext.undoManager	= nil;
		
    });
    
    return _sharedStorage;
	
}

- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL contextsSharePersistentStoreCoordinator:(BOOL)shared errorHandler:(GTStorageErrorHandler *)errorHandler {
	
	@try {
		
		self = [super initWithStoreURL:storeURL modelURL:modelURL contextsSharePersistentStoreCoordinator:shared];
		
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

@end