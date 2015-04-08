//
//  GTResourceLog.m
//  godtools
//
//  Created by Michael Harrison on 3/19/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTDefaults.h"
#import "GTStorage.h"
#import "GTLanguage+Helper.h"


NSString *const GTDefaultscurrentPackageCodeKey				= @"current_package_code";
NSString *const GTDefaultscurrentLanguageCodeKey			= @"current_language_code";
NSString *const GTDefaultscurrentParallelLanguageCodeKey	= @"current_parallel_language_code";

NSString *const GTDefaultsisChoosingForMainLanguage         = @"is_for_main_language";
NSString *const GTDefaultsisFirstLaunch                     = @"is_first_launch";
NSString *const GTDefaultsisInTranslatorMode                = @"is_in_translator_mode";

NSString *const GTDefaultstranslatorAccessCode              = @"translator_access_code";

NSString *const GTDefaultstranslationDownloadStatus         = @"translation_download_status";

@interface GTDefaults ()

@property (nonatomic, strong, readonly) NSString *phonesLanguageCode;

@end

@implementation GTDefaults

@synthesize currentPackageCode			= _currentPackageCode;
@synthesize currentLanguageCode			= _currentLanguageCode;
@synthesize currentParallelLanguageCode	= _currentParallelLanguageCode;

@synthesize isChoosingForMainLanguage   = _isChoosingForMainLanguage;
@synthesize isFirstLaunch               = _isFirstLaunch;
@synthesize isInTranslatorMode          = _isInTranslatorMode;

@synthesize translatorAccessCode        = _translatorAccessCode;
@synthesize translationDownloadStatus   = _translationDownloadStatus;


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
		//self.currentLanguageCode	= ( self.currentLanguageCode ? self.currentLanguageCode : self.phonesLanguageCode );
		
    }
	
    return self;
}

#pragma mark - phoneLanguageCode

- (NSString *)phonesLanguageCode {
	
	NSString		*language					= @"";
	
	NSArray			*preferredLanguages			= [NSLocale preferredLanguages];
	NSLocale		*currentLocale				= [NSLocale currentLocale];
    
    //NSLog(@"preferredLanguages %@",preferredLanguages);
    //NSLog(@"current Locale: %@", currentLocale.localeIdentifier);
	
	NSString		*phonesLanguage				= ( preferredLanguages.count > 0 ? preferredLanguages[0] : @"en" );
	NSString		*phonesLocale				= ( [currentLocale objectForKey:NSLocaleCountryCode] ? [currentLocale objectForKey:NSLocaleCountryCode] : @"" );
    NSString		*phonesLanguageWithLocale	= [phonesLanguage stringByAppendingFormat:@"_%@", phonesLocale];
    
    
	if ([self isValidLanguageCode:phonesLanguageWithLocale]) {
		
		language	= phonesLanguageWithLocale;
		
	} else if ([self isValidLanguageCode:phonesLanguage]) {
		
		language	= phonesLanguage;
		
    }else if([self checkIfChinese:phonesLanguage]){
        language    = @"zh";
    
    }else {
		
		//language	= @"en";
        language = nil;
		
	}

	return language;
}

-(BOOL)checkIfChinese:(NSString *)languageCode{
    return [languageCode isEqualToString:@"zh-Hans"] || [languageCode isEqualToString:@"zh-Hant"];
}

- (BOOL)isValidLanguageCode:(NSString *)languageCode {

    //get all languages
    NSArray *languages = [[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:languageCode inBackground:YES];
    
    if(languages.count > 0){
        //NSLog(@"%@ is valid",languageCode);
        return YES;
    }else{
        //NSLog(@"%@ is invalid",languageCode);
        return NO;
    }

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
    
    if([currentLanguageCode isEqualToString:_currentParallelLanguageCode]){
        [self setCurrentParallelLanguageCode:nil];
    }
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
    
    if (!_isFirstLaunch) {
        
        [self willChangeValueForKey:@"isFirstLaunch"];
        _isFirstLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:GTDefaultsisFirstLaunch];
        if(_isFirstLaunch == nil){
            [self setIsFirstLaunch:[NSNumber numberWithBool:YES]];
        }
        [self didChangeValueForKey:@"isFirstLaunch"];
    }
    
    return _isFirstLaunch;
}

#pragma mark - isFirstLaunch

-(void)setIsInTranslatorMode:(NSNumber *)isInTranslatorMode{
    [self willChangeValueForKey:@"isInTranslatorMode"];
    _isInTranslatorMode  = isInTranslatorMode;
    [self didChangeValueForKey:@"isInTranslatorMode"];
    
    [[NSUserDefaults standardUserDefaults]setObject:_isInTranslatorMode forKey:GTDefaultsisInTranslatorMode];
    
}
-(NSNumber*)isInTranslatorMode{
    if (!_isInTranslatorMode) {
        [self willChangeValueForKey:@"isInTranslatorMode"];
        _isInTranslatorMode = [[NSUserDefaults standardUserDefaults] objectForKey:GTDefaultsisInTranslatorMode];
        if(!_isInTranslatorMode){
            [self setIsInTranslatorMode:[NSNumber numberWithBool:NO]];
        }
        [self didChangeValueForKey:@"isInTranslatorMode"];
    }
    
    return _isInTranslatorMode;
}

#pragma mark - translatorAccessCode

- (void)setTranslatorAccessCode:(NSString *)translatorAccessCode{
    
    [self willChangeValueForKey:@"translatorAccessCode"];
    
    _translatorAccessCode	= translatorAccessCode;
    [self didChangeValueForKey:@"translatorAccessCode"];
    
    [[NSUserDefaults standardUserDefaults] setObject:translatorAccessCode forKey:GTDefaultstranslatorAccessCode];
    
}

- (NSString *)translatorAccessCode {
    
    if (!_translatorAccessCode) {
        
        [self willChangeValueForKey:@"translatorAccessCode"];
        _translatorAccessCode = [[NSUserDefaults standardUserDefaults] stringForKey:GTDefaultstranslatorAccessCode];
        [self didChangeValueForKey:@"translatorAccessCode"];
        
    }
    
    return _translatorAccessCode;
}

#pragma mark - translationDownloadStatus

-(void) setTranslationDownloadStatus :(NSString*) status{
    [self willChangeValueForKey:@"translationDownloadStatus"];
     
    _translationDownloadStatus	= status;
    [self didChangeValueForKey:@"translationDownloadStatus"];
     
    [[NSUserDefaults standardUserDefaults] setObject:status forKey:GTDefaultstranslationDownloadStatus];

}
- (NSString *)translationDownloadStatus {
    if (!_translationDownloadStatus) {
        
        [self willChangeValueForKey:@"translationDownloadStatus"];
        _translationDownloadStatus = [[NSUserDefaults standardUserDefaults] stringForKey:GTDefaultstranslationDownloadStatus];
        [self didChangeValueForKey:@"translationDownloadStatus"];
    }
    
    return _translationDownloadStatus;
}

@end
