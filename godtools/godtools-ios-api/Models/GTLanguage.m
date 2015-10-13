//
//  GTLanguage.m
//  godtools
//
//  Created by Michael Harrison on 10/13/15.
//  Copyright © 2015 Michael Harrison. All rights reserved.
//

#import "GTLanguage.h"
#import "GTPackage.h"

@implementation GTLanguage

+ (instancetype)languageWithCode:(NSString *)code inContext:(NSManagedObjectContext *)context {
	
	GTLanguage *language	= [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
	language.code			= code;
	
	return language;
}

- (NSComparisonResult)compare:(GTLanguage *)otherLanguage {
	return [self.name compare:otherLanguage.name];
}

- (BOOL)hasUpdates {
	return ( [self.updatesAvailable isEqual:@YES] ? YES : NO );
}

@end
