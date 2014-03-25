//
//  GTAPIErrorHandler.m
//  godtools
//
//  Created by Michael Harrison on 3/20/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTAPIErrorHandler.h"

@implementation GTAPIErrorHandler

+ (instancetype)sharedErrorHandler {
	
    static GTAPIErrorHandler *_sharedErrorHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		
        _sharedErrorHandler = [[GTAPIErrorHandler alloc] init];
		
    });
    
    return _sharedErrorHandler;
}

- (void)displayError:(NSError *)error {
	
#warning incomplete impelementation. Error specific handling should go here to catch general API errors like no connection.
	
	[super displayError:error];
}

@end
