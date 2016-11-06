//
//  GodToolsDeeplink.h
//  godtools
//
//  Created by Michael Harrison on 11/5/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import "Deeplink.h"

extern NSString * const GodToolsDeeplinkNotificationNameNavigation;
extern NSString * const GodToolsDeeplinkNotificationParameterNameNavigationParameter;

extern NSString * const GodToolsDeeplinkPatternParamNameLanguage;
extern NSString * const GodToolsDeeplinkPatternParamNamePackage;
extern NSString * const GodToolsDeeplinkPatternParamNamePage;
extern NSString * const GodToolsDeeplinkParamNameEvent;

#define DeeplinkLanguageCodeFormatGodTools DeeplinkLanguageCodeFormatISO639_3
#define DeeplinkLanguageCodeFormatJesusFilm DeeplinkLanguageCodeFormatBCP_47

@interface GodToolsDeeplink : Deeplink

- (NSString *)patternWithLanguagePackageAndPage;
- (NSString *)patternWithLanguageAndPackage;
- (NSString *)patternWithLanguage;
- (NSString *)patternWithPackageAndPage;
- (NSString *)patternWithPackage;

- (instancetype)setPackageWithCode:(NSString *)code;
- (instancetype)setLanguageWithCode:(NSString *)code;
- (instancetype)setLanguageWithCode:(NSString *)code format:(DeeplinkLanguageCodeFormat)format;
- (instancetype)setPageWithPageNumber:(NSUInteger)pageNumber;
- (instancetype)addEventWithName:(NSString *)event;

@end
