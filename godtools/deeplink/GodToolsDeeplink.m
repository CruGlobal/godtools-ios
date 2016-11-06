//
//  GodToolsDeeplink.m
//  godtools
//
//  Created by Michael Harrison on 11/5/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import "GodToolsDeeplink.h"
#import "Deeplink+helpers.h"

NSString * const GodToolsDeeplinkPatternParamNameLanguage	= @":language_code";
NSString * const GodToolsDeeplinkPatternParamNamePackage	= @":package_code";
NSString * const GodToolsDeeplinkPatternParamNamePage		= @":page_number";
NSString * const GodToolsDeeplinkParamNameEvent				= @"event";

@interface GodToolsDeeplink () <DeeplinkInternalInterface>

@property (nonatomic, assign) BOOL hasPackageCode;
@property (nonatomic, assign) BOOL hasLanguageCode;
@property (nonatomic, assign) BOOL hasPageNumber;

@end

@implementation GodToolsDeeplink

#pragma mark - DeeplinkInternalInterface

- (NSString *)appID {
	return @"org.cru.godtools";
}

- (NSString *)pathComponentPattern {
	
	if (self.hasLanguageCode && self.hasPackageCode && self.hasPageNumber) {
		return self.patternWithLanguagePackageAndPage;
	} else if (self.hasLanguageCode && self.hasPackageCode) {
		return self.patternWithLanguageAndPackage;
	} else if (self.hasLanguageCode) {
		return self.patternWithLanguage;
	} else if (self.hasPackageCode && self.hasPageNumber) {
		return self.patternWithPackageAndPage;
	} else if (self.hasPackageCode) {
		return self.patternWithPackage;
	}
	
	return nil;
}

#pragma mark - patterns

- (NSString *)patternWithLanguagePackageAndPage {
	return [NSString stringWithFormat:@"%@/%@/%@",
			GodToolsDeeplinkPatternParamNameLanguage,
			GodToolsDeeplinkPatternParamNamePackage,
			GodToolsDeeplinkPatternParamNamePage];
}

- (NSString *)patternWithLanguageAndPackage {
	return [NSString stringWithFormat:@"%@/%@",
			GodToolsDeeplinkPatternParamNameLanguage,
			GodToolsDeeplinkPatternParamNamePackage];
}

- (NSString *)patternWithLanguage {
	return [NSString stringWithFormat:@"%@",
			GodToolsDeeplinkPatternParamNameLanguage];
}

- (NSString *)patternWithPackageAndPage {
	return [NSString stringWithFormat:@"%@/%@",
			GodToolsDeeplinkPatternParamNamePackage,
			GodToolsDeeplinkPatternParamNamePage];
}

- (NSString *)patternWithPackage {
	return [NSString stringWithFormat:@"%@",
			GodToolsDeeplinkPatternParamNamePackage];
}

#pragma mark - init

+ (instancetype)generate {
	
	return [[self alloc] init];
}

#pragma mark - public methods

- (instancetype)setPackageWithCode:(NSString *)code {
	
	if (!code) {
		return self;
	}
	
	self.hasPackageCode = YES;
	
	return [self addPathComponentWithName:@":package_code"
									value:code];
}

- (instancetype)setLanguageWithCode:(NSString *)code {
	
	return [self setLanguageWithCode:code
							  format:DeeplinkLanguageCodeFormatGodTools];
}

- (instancetype)setLanguageWithCode:(NSString *)code
							 format:(DeeplinkLanguageCodeFormat)format {
	
	if (!code) {
		return self;
	}
	
	NSString *mappedLanguageCode = [self mapLanguageCode:code
											  fromFormat:format
												toFormat:DeeplinkLanguageCodeFormatGodTools];
	
	if (!mappedLanguageCode) {
		return self;
	}
	
	self.hasLanguageCode = YES;
	
	return [self addPathComponentWithName:@":language_code"
									value:code];
}

- (instancetype)setPageWithPageNumber:(NSUInteger)pageNumber {
	
	self.hasPageNumber = YES;
	
	return [self addPathComponentWithName:@":page_number"
									value:((NSNumber *)@(pageNumber)).stringValue];
}

- (instancetype)addEventWithName:(NSString *)event {
	return [self addParamWithName:GodToolsDeeplinkParamNameEvent
							value:event];
}

#pragma mark - private methods

- (NSString *)mapLanguageCode:(NSString *)code
				   fromFormat:(DeeplinkLanguageCodeFormat)fromFormat
					 toFormat:(DeeplinkLanguageCodeFormat)toFormat {
	
	if (fromFormat == toFormat) {
		return code;
	} else {
		//TODO: do actual mapping
		return code;
	}
	
}

@end
