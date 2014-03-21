//
//  GTResourceLog.m
//  godtools
//
//  Created by Michael Harrison on 3/19/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTDefaults.h"

NSString *const GTDefaultsCurrentPackageKey				= @"current_package";
NSString *const GTDefaultsCurrentLanguageKey			= @"current_language";
NSString *const GTDefaultsCurrentParallelLanguageKey	= @"current_parallel_language";

@implementation GTDefaults

@synthesize currentPackage			= _currentPackage;
@synthesize currentLanguage			= _currentLanguage;
@synthesize currentParallelLanguage	= _currentParallelLanguage;

- (void)setCurrentPackage:(NSString *)currentPackage {
	
	[self willChangeValueForKey:@"currentPackage"];
	_currentPackage	= currentPackage;
	[self didChangeValueForKey:@"currentPackage"];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentPackage forKey:GTDefaultsCurrentPackageKey];
	
}

- (NSString *)currentPackage {
	
	if (!_currentPackage) {
		
		[self willChangeValueForKey:@"currentPackage"];
		_currentPackage = [[NSUserDefaults standardUserDefaults] stringForKey:GTDefaultsCurrentPackageKey];
		[self didChangeValueForKey:@"currentPackage"];
		
	}
	
	return _currentPackage;
}

- (void)setCurrentLanguage:(NSString *)currentLanguage {
	
	[self willChangeValueForKey:@"currentLanguage"];
	_currentLanguage	= currentLanguage;
	[self didChangeValueForKey:@"currentLanguage"];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentLanguage forKey:GTDefaultsCurrentLanguageKey];
	
}

- (NSString *)currentLanguage {
	
	if (!_currentLanguage) {
		
		[self willChangeValueForKey:@"currentLanguage"];
		_currentLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:GTDefaultsCurrentLanguageKey];
		[self didChangeValueForKey:@"currentLanguage"];
		
	}
	
	return _currentLanguage;
}

- (void)setCurrentParallelLanguage:(NSString *)currentParallelLanguage {
	
	[self willChangeValueForKey:@"currentParallelLanguage"];
	_currentParallelLanguage	= currentParallelLanguage;
	[self didChangeValueForKey:@"currentParallelLanguage"];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentParallelLanguage forKey:GTDefaultsCurrentParallelLanguageKey];
	
}

- (NSString *)currentParallelLanguage {
	
	if (!_currentParallelLanguage) {
		
		[self willChangeValueForKey:@"currentParallelLanguage"];
		_currentParallelLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:GTDefaultsCurrentParallelLanguageKey];
		[self didChangeValueForKey:@"currentParallelLanguage"];
		
	}
	
	return _currentParallelLanguage;
}

@end
