//
//  GodToolsDeeplink.m
//  godtools
//
//  Created by Michael Harrison on 11/5/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import "GodToolsDeeplink.h"
#import "Deeplink+helpers.h"

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
		return @":language_code/:package_code/:page_number";
	} else if (self.hasPackageCode && self.hasPageNumber) {
		return @":package_code/:page_number";
	}
	
	return nil;
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
