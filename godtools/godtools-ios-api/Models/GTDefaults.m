//
//  GTResourceLog.m
//  godtools
//
//  Created by Michael Harrison on 3/19/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTDefaults.h"
<<<<<<< HEAD
=======
#import "GTStorage.h"
#import "GTLanguage+Helper.h"
>>>>>>> refs/heads/elementzMaster

NSString *const GTDefaultscurrentPackageCodeKey				= @"current_package_code";
NSString *const GTDefaultscurrentLanguageCodeKey			= @"current_language_code";
NSString *const GTDefaultscurrentParallelLanguageCodeKey	= @"current_parallel_language_code";
<<<<<<< HEAD
=======
NSString *const GTDefaultsisChoosingForMainLanguage         = @"is_for_main_language";
NSString *const GTDefaultsisFirstLaunch                     = @"is_first_launch";
>>>>>>> refs/heads/elementzMaster

@interface GTDefaults ()

@property (nonatomic, strong, readonly) NSString *phonesLanguageCode;

@end

@implementation GTDefaults

@synthesize currentPackageCode			= _currentPackageCode;
@synthesize currentLanguageCode			= _currentLanguageCode;
@synthesize currentParallelLanguageCode	= _currentParallelLanguageCode;
<<<<<<< HEAD
=======
@synthesize isChoosingForMainLanguage   = _isChoosingForMainLanguage;
@synthesize isFirstLaunch               = _isFirstLaunch;
>>>>>>> refs/heads/elementzMaster

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
		
<<<<<<< HEAD
		self.currentLanguageCode	= ( self.currentLanguageCode ? self.currentLanguageCode : self.phonesLanguageCode );
=======
		//self.currentLanguageCode	= ( self.currentLanguageCode ? self.currentLanguageCode : self.phonesLanguageCode );
>>>>>>> refs/heads/elementzMaster
		
    }
	
    return self;
}

#pragma mark - phoneLanguageCode

- (NSString *)phonesLanguageCode {
	
	NSString		*language					= @"";
	
	NSArray			*preferredLanguages			= [NSLocale preferredLanguages];
	NSLocale		*currentLocale				= [NSLocale currentLocale];
<<<<<<< HEAD
	
	NSString		*phonesLanguage				= ( preferredLanguages.count > 0 ? preferredLanguages[0] : @"en" );
	NSString		*phonesLocale				= ( [currentLocale objectForKey:NSLocaleCountryCode] ? [currentLocale objectForKey:NSLocaleCountryCode] : @"" );
    NSString		*phonesLangageWithLocale	= [phonesLanguage stringByAppendingFormat:@"_%@", phonesLocale];
	
	if ([self isValidLanguageCode:phonesLangageWithLocale]) {
		
		language	= phonesLangageWithLocale;
		
	} else if ([self isValidLanguageCode:phonesLangageWithLocale]) {
=======
    
    //NSLog(@"preferredLanguages %@",preferredLanguages);
    //NSLog(@"current Locale: %@", currentLocale);
	
	NSString		*phonesLanguage				= ( preferredLanguages.count > 0 ? preferredLanguages[0] : @"en" );
	NSString		*phonesLocale				= ( [currentLocale objectForKey:NSLocaleCountryCode] ? [currentLocale objectForKey:NSLocaleCountryCode] : @"" );
    NSString		*phonesLanguageWithLocale	= [phonesLanguage stringByAppendingFormat:@"_%@", phonesLocale];
	
	if ([self isValidLanguageCode:phonesLanguageWithLocale]) {
		
		language	= phonesLanguageWithLocale;
		
	} else if ([self isValidLanguageCode:phonesLanguage]) {
>>>>>>> refs/heads/elementzMaster
		
		language	= phonesLanguage;
		
	} else {
		
		language	= @"en";
		
	}
<<<<<<< HEAD
	
=======
    NSLog(@"LANGUAGE at phonesLanguageCode: %@",language);
>>>>>>> refs/heads/elementzMaster
	return language;
}

- (BOOL)isValidLanguageCode:(NSString *)languageCode {
	
<<<<<<< HEAD
#warning incomplete impelementation of isValidLanguageCode
	
	return YES;
=======
    //get all languages
    NSArray *languages = [[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:languageCode inBackground:YES];
    
    if(languages.count > 0){
        NSLog(@"%@ is valid",languageCode);
        return YES;
    }else{
        NSLog(@"%@ is invalid",languageCode);
        return NO;
    }
>>>>>>> refs/heads/elementzMaster
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
<<<<<<< HEAD
=======
    
    if([currentLanguageCode isEqualToString:_currentParallelLanguageCode]){
        [self setCurrentParallelLanguageCode:nil];
    }
>>>>>>> refs/heads/elementzMaster
	_currentLanguageCode	= currentLanguageCode;
	[self didChangeValueForKey:@"currentLanguageCode"];
    
    [[NSUserDefaults standardUserDefaults] setObject:currentLanguageCode forKey:GTDefaultscurrentLanguageCodeKey];
	
}

- (NSString *)currentLanguageCode {
	
	if (!_currentLanguageCode) {
		
		[self willChangeValueForKey:@"currentLanguageCode"];
		_currentLanguageCode = [[NSUserDefaults standardUserDefaults] stringForKey:GTDefaultscurrentLanguageCodeKey];
<<<<<<< HEAD
=======
        NSLog(@"_currentLanguageCode: %@",_currentLanguageCode);
>>>>>>> refs/heads/elementzMaster
		[self didChangeValueForKey:@"currentLanguageCode"];
		
	}
	
	return _currentLanguageCode;
}

#pragma mark - currentParallelLanguageCode

- (void)setCurrentParallelLanguageCode:(NSString *)currentParallelLanguageCode {
	
<<<<<<< HEAD
	[self willChangeValueForKey:@"currentParallelLanguageCode"];
=======
    [self willChangeValueForKey:@"currentParallelLanguageCode"];
    
>>>>>>> refs/heads/elementzMaster
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

<<<<<<< HEAD
=======
#pragma mark - Choosing Main Language

-(void)setIsChoosingForMainLanguage:(NSNumber*)isChoosingForMainLanguage{
    [self willChangeValueForKey:@"isChoosingForMainLanguage"];
    _isChoosingForMainLanguage	= isChoosingForMainLanguage;
    [self didChangeValueForKey:@"isChoosingForMainLanguage"];
    
    [[NSUserDefaults standardUserDefaults]setObject:_isChoosingForMainLanguage forKey:GTDefaultsisChoosingForMainLanguage];

}

-(NSNumber*)isChoosingForMainLanguage{
    if (!_isChoosingForMainLanguage) {
        
        [self willChangeValueForKey:@"isChoosingForMainLanguage"];
        _isChoosingForMainLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:GTDefaultsisChoosingForMainLanguage];
        [self didChangeValueForKey:@"isChoosingForMainLanguage"];
    }

    return _isChoosingForMainLanguage;
}

#pragma mark - isFirstLaunch

-(void)setIsFirstLaunch:(NSNumber *)isFirstLaunch{
    [self willChangeValueForKey:@"isFirstLaunch"];
    _isFirstLaunch	= isFirstLaunch;
    [self didChangeValueForKey:@"isFirstLaunch"];
    
    [[NSUserDefaults standardUserDefaults]setObject:_isFirstLaunch forKey:GTDefaultsisFirstLaunch];
    
}
-(NSNumber*)isFirstLaunch{
    NSLog(@"get is first launch");
    if (!_isFirstLaunch) {
        NSLog(@"!_isfirstlaunch");
        [self willChangeValueForKey:@"isFirstLaunch"];
        _isFirstLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:GTDefaultsisFirstLaunch];
        if(!_isFirstLaunch){
            [self setIsFirstLaunch:[NSNumber numberWithBool:YES]];
        }
        [self didChangeValueForKey:@"isFirstLaunch"];
    }
    
    return _isFirstLaunch;
}


>>>>>>> refs/heads/elementzMaster
@end
