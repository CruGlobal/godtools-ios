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
					 contextsSharePersistentStoreCoordinator:YES];
		
    });
    
    return _sharedStorage;
	
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