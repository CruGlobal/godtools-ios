//
//  GTStorage.h
//  godtools
//
//  Created by Michael Harrison on 3/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "CRUStorage.h"
#import "GTStorageErrorHandler.h"

@interface GTStorage : CRUStorage

+ (instancetype)sharedStorage;
- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL contextsSharePersistentStoreCoordinator:(BOOL)shared errorHandler:(GTStorageErrorHandler *)errorHandler;

@property (nonatomic, strong, readonly) GTStorageErrorHandler *errorHandler;

@end
