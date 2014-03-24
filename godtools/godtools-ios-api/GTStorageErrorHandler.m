//
//  GTStorageErrorHandler.m
//  godtools
//
//  Created by Michael Harrison on 3/24/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTStorageErrorHandler.h"

@implementation GTStorageErrorHandler

+ (instancetype)sharedErrorHandler {
	
    static GTStorageErrorHandler *_sharedErrorHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		
        _sharedErrorHandler = [[GTStorageErrorHandler alloc] init];
		
    });
    
    return _sharedErrorHandler;
}

@end
