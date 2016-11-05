//
//  GodToolsDeeplink.h
//  godtools
//
//  Created by Michael Harrison on 11/5/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import "Deeplink.h"

typedef NS_ENUM(NSInteger, DeeplinkLanguageCodeFormat) {
	DeeplinkLanguageCodeFormatISO639_3,
	DeeplinkLanguageCodeFormatBCP_47
};

#define DeeplinkLanguageCodeFormatGodTools DeeplinkLanguageCodeFormatISO639_3
#define DeeplinkLanguageCodeFormatJesusFilm DeeplinkLanguageCodeFormatBCP_47

@interface GodToolsDeeplink : Deeplink

+ (instancetype)generate;

- (instancetype)setPackageWithCode:(NSString *)code;
- (instancetype)setLanguageWithCode:(NSString *)code;
- (instancetype)setLanguageWithCode:(NSString *)code format:(DeeplinkLanguageCodeFormat)format;
- (instancetype)setPageWithPageNumber:(NSUInteger)pageNumber;

@end
