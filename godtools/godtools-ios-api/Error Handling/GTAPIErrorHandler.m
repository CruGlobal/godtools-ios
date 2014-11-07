//
//  GTAPIErrorHandler.m
//  godtools
//
//  Created by Michael Harrison on 3/20/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTAPIErrorHandler.h"

@implementation GTAPIErrorHandler

- (void)displayError:(NSError *)error {
	
#warning incomplete impelementation. Error specific handling should go here to catch general API errors like no connection.
	NSLog(@"API Error: %@", error);
	//[super displayError:error];
}

@end
