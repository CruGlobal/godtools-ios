//
//  GTLanguage+Helper.m
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTLanguage+Helper.h"

@implementation GTLanguage (Helper)

+ (instancetype)languageWithCode:(NSString *)code inContext:(NSManagedObjectContext *)context {
	
	GTLanguage *language	= [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
	language.code			= code;
	
	return language;
}

- (NSComparisonResult)compare:(GTLanguage *)otherLanguage {
    return [self.name compare:otherLanguage.name];
}

- (BOOL)hasUpdates {

	if (self.updatesAvailable == [NSNumber numberWithBool:YES]) {
		return YES;
	} else {
		return NO;
	}
	
}

@end
