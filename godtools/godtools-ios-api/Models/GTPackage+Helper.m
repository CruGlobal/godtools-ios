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
	
	NSString *latestString	= (!self.latestVersion || self.latestVersion.length == 0 ? @"0.0.0" : self.latestVersion);
	NSString *localString	= (!self.localVersion || self.localVersion.length == 0 ? @"0.0.0" : self.localVersion);
	EDSemver *latest		= [EDSemver semverWithString:latestString];
	EDSemver *local			= [EDSemver semverWithString:localString];
	
	if ([latest isGreaterThan: local]) {
		return YES;
	} else {
		return NO;
	}

}

- (BOOL)needsMajorUpdate {
	
	NSString *latestString	= (!self.latestVersion || self.latestVersion.length == 0 ? @"0.0.0" : self.latestVersion);
	NSString *localString	= (!self.localVersion || self.localVersion.length == 0 ? @"0.0.0" : self.localVersion);
	EDSemver *latest		= [EDSemver semverWithString:latestString];
	EDSemver *local			= [EDSemver semverWithString:localString];
	
	if (latest.major > local.major) {
		return YES;
	} else {
		return NO;
	}
	
}

- (BOOL)needsMinorUpdate {
	
	NSString *latestString	= (!self.latestVersion || self.latestVersion.length == 0 ? @"0.0.0" : self.latestVersion);
	NSString *localString	= (!self.localVersion || self.localVersion.length == 0 ? @"0.0.0" : self.localVersion);
	EDSemver *latest		= [EDSemver semverWithString:latestString];
	EDSemver *local			= [EDSemver semverWithString:localString];
	
	if (latest.major == local.major && latest.minor > local.minor) {
		return YES;
	} else {
		return NO;
	}
	
}

- (void)setIfGreaterThanLatestVersion:(NSString *)latestVersion {
	
	NSString *latestString			= (!self.latestVersion || self.latestVersion.length == 0 ? @"0.0.0" : self.latestVersion);
	NSString *newLatestString		= (!latestVersion || latestVersion.length == 0 ? @"0.0.0" : latestVersion);
	EDSemver *storedLatestVersion	= [EDSemver semverWithString:latestString];
	EDSemver *newLastestVersion		= [EDSemver semverWithString:newLatestString];
	
	if ([newLastestVersion isGreaterThan:storedLatestVersion]) {
		
		self.latestVersion = latestVersion;
	}
	
}

@end
