//
//  GTPackage+Helper.m
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTPackage+Helper.h"

#import "GTLanguage+Helper.h"
#import "EDSemver.h"

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

- (BOOL)needsUpdate {
	
	EDSemver *latest	= [EDSemver semverWithString:self.latestVersion];
	EDSemver *local		= [EDSemver semverWithString:self.localVersion];
	
	if ([latest isGreaterThan: local]) {
		return YES;
	} else {
		return NO;
	}

}

- (BOOL)needsMajorUpdate {
	
	EDSemver *latest	= [EDSemver semverWithString:self.latestVersion];
	EDSemver *local		= [EDSemver semverWithString:self.localVersion];
	
	if (latest.major > local.major) {
		return YES;
	} else {
		return NO;
	}
	
}

- (BOOL)needsMinorUpdate {
	
	EDSemver *latest	= [EDSemver semverWithString:self.latestVersion];
	EDSemver *local		= [EDSemver semverWithString:self.localVersion];
	
	if (latest.major == local.major && latest.minor > local.minor) {
		return YES;
	} else {
		return NO;
	}
	
}

@end
