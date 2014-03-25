//
//  GTPackage+Helper.m
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTPackage+Helper.h"

#import "GTLanguage+Helper.h"

@implementation GTPackage (Helper)

+ (instancetype)packageWithCode:(NSString *)code language:(GTLanguage *)language inContext:(NSManagedObjectContext *)context {
	
	GTPackage *package	= [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
	package.code		= code;
	package.identifier	= [self identifierWithPackageCode:code languageCode:language.code];
	package.language	= language;
	
	return package;
}

+ (NSString *)identifierWithPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode {
	
	return [packageCode stringByAppendingFormat:@"-%@", languageCode];
}

@end
