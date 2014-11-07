//
//  GTResourceLog.m
//  godtools
//
//  Created by Michael Harrison on 3/19/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTDefaults.h"

NSString *const GTDefaultscurrentPackageCodeKey				= @"current_package_code";
NSString *const GTDefaultscurrentLanguageCodeKey			= @"current_language_code";
NSString *const GTDefaultscurrentParallelLanguageCodeKey	= @"current_parallel_language_code";

@interface GTDefaults ()

@property (nonatomic, strong, readonly) NSString *phonesLanguageCode;

@end

@implementation GTDefaults

@synthesize currentPackageCode			= _currentPackageCode;
@synthesize currentLanguageCode			= _currentLanguageCode;
@synthesize currentParallelLanguageCode	= _currentParallelLanguageCode;

#pragma mark - initialization

+ (instancetype)sharedDefaults {
	
    static GTDefaults *_sharedDefaults = nil;
    static dispatch_once_t onceToken;
    
	dispatch_once(&onceToken, ^{
		
        _sharedDefaults = [[GTDefaults alloc] init];
		
    });
    
    return _sharedDefaults;
}

- (instancetype)init {
	
    self = [super init];
    
	if (self) {
		
		self.currentLanguageCode	= ( self.currentLanguageCode ? self.currentLanguageCode : self.phonesLanguageCode );
		
    }
	
    return self;
}

#pragma mark - phoneLanguageCode

- (NSString *)phonesLanguageCode {
	
	NSString		*language					= @"";
	
	NSArray			*preferredLanguages			= [NSLocale preferredLanguages];
	NSLocale		*currentLocale				= [NSLocale currentLocale];
	
	NSString		*phonesLanguage				= ( preferredLanguages.count > 0 ? preferredLanguages[0] : @"en" );
	NSString		*phonesLocale				= ( [currentLocale objectForKey:NSLocaleCountryCode] ? [currentLocale objectForKey:NSLocaleCountryCode] : @"" );
    NSString		*phonesLangageWithLocale	= [phonesLanguage stringByAppendingFormat:@"_%@", phonesLocale];
	
	if ([self isValidLanguageCode:phonesLangageWithLocale]) {
		
		language	= phonesLangageWithLocale;
		
	} else if ([self isValidLanguageCode:phonesLangageWithLocale]) {
		
		language	= phonesLanguage;
		
	} else {
		
		language	= @"en";
		
	}
	
	return language;
}

- (BOOL)isValidLanguageCode:(NSString *)languageCode {
	
#warning incomplete impelementation of isValidLanguageCode
	
	return YES;
}

#pragma mark - currentPackageCode

- (void)setCurrentPackageCode:(NSString *)currentPackageCode {
	
	[self willChangeValueForKey:@"currentPackageCode"];
	_currentPackageCode	= currentPackageCode;
	[self didChangeValueForKey:@"currentPackageCode"];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentPackageCode forKey:GTDefaultscurrentPackageCodeKey];
	
}

- (NSString *)currentPackageCode {
	
	if (!_currentPackageCode) {
		
		[self willChangeValueForKey:@"currentPackageCode"];
		_currentPackageCode = [[NSUserDefaults standardUserDefaults] stringForKey:GTDefaultscurrentPackageCodeKey];
		[self didChangeValueForKey:@"currentPackageCode"];
		
	}
	
	return _currentPackageCode;
}

#pragma mark - currentLanguageCode

- (void)setCurrentLanguageCode:(NSString *)currentLanguageCode {
	
	[self willChangeValueForKey:@"currentLanguageCode"];
	_currentLanguageCode	= currentLanguageCode;
	[self didChangeValueForKey:@"currentLanguageCode"];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentLanguageCode forKey:GTDefaultscurrentLanguageCodeKey];
	
}

- (NSString *)currentLanguageCode {
	
	if (!_currentLanguageCode) {
		
		[self willChangeValueForKey:@"currentLanguageCode"];
		_currentLanguageCode = [[NSUserDefaults standardUserDefaults] stringForKey:GTDefaultscurrentLanguageCodeKey];
		[self didChangeValueForKey:@"currentLanguageCode"];
		
	}
	
	return _currentLanguageCode;
}

#pragma mark - currentParallelLanguageCode

- (void)setCurrentParallelLanguageCode:(NSString *)currentParallelLanguageCode {
	
	[self willChangeValueForKey:@"currentParallelLanguageCode"];
	_currentParallelLanguageCode	= currentParallelLanguageCode;
	[self didChangeValueForKey:@"currentParallelLanguageCode"];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentParallelLanguageCode forKey:GTDefaultscurrentParallelLanguageCodeKey];
	
}

- (NSString *)currentParallelLanguageCode {
	
	if (!_currentParallelLanguageCode) {
		
		[self willChangeValueForKey:@"currentParallelLanguageCode"];
		_currentParallelLanguageCode = [[NSUserDefaults standardUserDefaults] stringForKey:GTDefaultscurrentParallelLanguageCodeKey];
		[self didChangeValueForKey:@"currentParallelLanguageCode"];
		
	}
	
	return _currentParallelLanguageCode;
}

@end
