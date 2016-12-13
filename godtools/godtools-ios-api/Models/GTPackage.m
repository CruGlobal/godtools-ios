//
//  GTPackage.m
//  godtools
//
//  Created by Michael Harrison on 10/13/15.
//  Copyright © 2015 Michael Harrison. All rights reserved.
//

#import "GTPackage.h"
#import "GTLanguage.h"
#import "EDSemver.h"

@implementation GTPackage

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

- (NSString *)localVersion {
	return (!self.localSemanticVersion || self.localSemanticVersion.length == 0 ? @"0.0.0" : self.localSemanticVersion);
}

- (void)setLocalVersion:(NSString *)localVersion {
	EDSemver *version;
	
	[self willChangeValueForKey:@"localVersion"];
	
	self.localSemanticVersion = localVersion;
	if (localVersion) {
		version = [EDSemver semverWithString:localVersion];
	}
	self.localMajorVersion = ( version ? @(version.major) : @0 );
	self.localMinorVersion = ( version ? @(version.minor) : @0 );
	
	[self didChangeValueForKey:@"localVersion"];
}

- (NSString *)latestVersion {
	return (!self.latestSemanticVersion || self.latestSemanticVersion.length == 0 ? @"0.0.0" : self.latestSemanticVersion);
}

- (void)setLatestVersion:(NSString *)latestVersion {
	EDSemver *version;
	
	[self willChangeValueForKey:@"latestVersion"];
	
	self.latestSemanticVersion = latestVersion;
	if (latestVersion) {
		version = [EDSemver semverWithString:latestVersion];
	}
	self.latestMajorVersion = ( version ? @(version.major) : @0 );
	self.latestMinorVersion = ( version ? @(version.minor) : @0 );
	
	[self didChangeValueForKey:@"latestVersion"];
}

- (BOOL)needsUpdate {
	EDSemver *latest		= [EDSemver semverWithString:self.latestVersion];
	EDSemver *local			= [EDSemver semverWithString:self.localVersion];

    return [latest isGreaterThan: local];
}

- (BOOL)needsMajorUpdate {
	
	return self.latestMajorVersion > self.localMajorVersion;
}

- (BOOL)needsMinorUpdate {
	
	return (self.latestMajorVersion == self.localMajorVersion && self.latestMinorVersion > self.localMinorVersion);
}

- (void)setIfGreaterThanLatestVersion:(NSString *)latestVersion {
	
	NSString *newLatestString		= (!latestVersion || latestVersion.length == 0 ? @"0.0.0" : latestVersion);
	EDSemver *storedLatestVersion	= [EDSemver semverWithString:self.latestVersion];
	EDSemver *newLastestVersion		= [EDSemver semverWithString:newLatestString];
	
	if ([newLastestVersion isGreaterThan:storedLatestVersion]) {
		
		self.latestVersion = latestVersion;
	}
	
}

@end
