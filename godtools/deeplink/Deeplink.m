//
//  Deeplink.m
//  godtools
//
//  Created by Michael Harrison on 11/5/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import "Deeplink.h"
#import "Deeplink+helpers.h"
#import <UIKit/UIKit.h>
#import <AdSupport/ASIdentifierManager.h>
#import <JLRoutes/JLRoutes.h>

NSString * const DeeplinkBaseURLScheme				= @"https";
NSString * const DeeplinkBaseURLHost				= @"hack-click-server.herokuapp.com";
NSString * const DeeplinkBaseURLHostPathPrefix		= @"/deeplink";

NSString * const DeeplinkParamNameReferrerAppID		= @"referrer";
NSString * const DeeplinkParamNameReferrerUserID	= @"referrer_user_id";
NSString * const DeeplinkParamNameDeviceID			= @"device_id";
NSString * const DeeplinkParamNamePlatform			= @"platform";
NSString * const DeeplinkParamValuePlatform			= @"ios";
NSString * const DeeplinkParamNameVersionNumber		= @"version_number";

#define DEEPLINK_CURRENT_VERSION_NUMBER @1

NSString * const DeeplinkLookupParamNamePath		= @"param-name-for-path"; //TODO: lookup real value
NSString * const DeeplinkLookupParamNameParams		= @"param-name-for-params"; //TODO: lookup real value

@interface Deeplink ()

@property (nonatomic, strong, readonly) NSURLComponents		*base;
@property (nonatomic, strong, readonly) NSString			*appID;
@property (nonatomic, strong)			NSURL				*finalDeeplink;

@property (nonatomic, strong)			NSMutableDictionary *params;
@property (nonatomic, strong)			NSString			*pathComponentPattern;
@property (nonatomic, strong)			NSMutableDictionary	*pathComponents;

@end

@implementation Deeplink

+ (instancetype)generate {
	
	return [[self alloc] init];
}

+ (instancetype)parse {
	
	id<DeeplinkParserInternalInterface> parser = [[self alloc] init];
	
	[parser registerHandlers];
	
	return parser;
}

- (instancetype)init {
	
	self = [super init];
	
	if (!self) {
		return nil;
	}
	
	_base			= [[NSURLComponents alloc] init];
	_base.scheme	= DeeplinkBaseURLScheme;
	_base.host		= DeeplinkBaseURLHost;
	_base.path		= DeeplinkBaseURLHostPathPrefix;
	_params			= [NSMutableDictionary dictionary];
	_pathComponents	= [NSMutableDictionary dictionary];
	
	return self;
}

#pragma mark - parser methods

- (NSURL *)baseURLForApp {
	
	if (self.appID) {
		return self.base.URL;
	}
	
	return [self.base.URL URLByAppendingPathComponent:self.appID];
}

- (instancetype)openDeeplinkURL:(NSURL *)deeplinkURL {
	
	[JLRoutes routeURL:deeplinkURL ?: self.baseURLForApp];
	
	return self;
}

- (instancetype)openDeeplinkHash:(NSDictionary *)deeplinkHash {
	
	NSURLComponents *fullURLComponents	= self.base.copy;
	
	NSString *path					= [self pathWithContentPathPattern:deeplinkHash[DeeplinkLookupParamNamePath]
												 contentPathParameters:@{}];
	fullURLComponents.path			= path;
	NSDictionary *params			= deeplinkHash[DeeplinkLookupParamNameParams];
	fullURLComponents.queryItems	= [self queryParamItemsWithParams:params];
	
	[self openDeeplinkURL:fullURLComponents.URL];
	
	return self;
}

- (instancetype)registerReferrerWithAppID:(NSString *)referrerAppID {
	
	return [self registerReferrerWithAppID:referrerAppID
							referrerUserID:nil];
}

- (instancetype)registerReferrerWithAppID:(NSString *)referrerAppID
						   referrerUserID:(NSString *)referrerUserID {
	
	if (referrerAppID) {
		[self addParamWithName:DeeplinkParamNameReferrerAppID
						 value:referrerAppID];
	}
	
	if (referrerUserID) {
		[self addParamWithName:DeeplinkParamNameReferrerUserID
						 value:referrerUserID];
	}
	
	return self;
}

- (instancetype)build {
	
	NSURLComponents *fullURLComponents	= self.base.copy;
	
	fullURLComponents.path			= self.fullPath;
	fullURLComponents.queryItems	= self.queryParamItems;
	
	self.finalDeeplink = fullURLComponents.URL;
	
	return self;
}

- (instancetype)open {
	
	if (!self.finalDeeplink) {
		[self build];
	}
	
	[[UIApplication sharedApplication] openURL:self.finalDeeplink];
	
	return self;
}

#pragma mark - private methods

- (NSString *)deviceID {
	return [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString ?: @"";
}

- (NSArray <NSURLQueryItem *>*)queryParamItems {
	
	NSMutableArray <NSURLQueryItem *>*queryParamItems = [NSMutableArray arrayWithArray:@[
																						 [NSURLQueryItem queryItemWithName:DeeplinkParamNameDeviceID
																													 value:self.deviceID],
																						 [NSURLQueryItem queryItemWithName:DeeplinkParamNamePlatform
																													 value:DeeplinkParamValuePlatform],
																						 [NSURLQueryItem queryItemWithName:DeeplinkParamNameVersionNumber
																													 value:DEEPLINK_CURRENT_VERSION_NUMBER.stringValue]
																						 ]];
	NSArray <NSURLQueryItem *> *userQueryParamItems = [self queryParamItemsWithParams:self.params];
	
	[queryParamItems addObjectsFromArray:userQueryParamItems];
	
	return queryParamItems;
}

- (NSArray <NSURLQueryItem *>*)queryParamItemsWithParams:(NSDictionary *)params {
	
	NSMutableArray <NSURLQueryItem *>*queryParamItems = [NSMutableArray array];
	
	for (NSString *queryParamName in params) {
		NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:queryParamName
																value:params[queryParamName]];
		if (queryParamItems) {
			[queryParamItems addObject:queryItem];
		}
	}
	
	return queryParamItems;
}

- (NSString *)fullPath {
	
	return [self pathWithContentPathPattern:self.pathComponentPattern
					  contentPathParameters:self.pathComponents];
}

- (NSString *)pathWithContentPathPattern:(NSString *)pattern
				   contentPathParameters:(NSDictionary *)parameters {
	
	NSString *fullPattern = @":prefix/:app_id/:content";
	NSString *contentString;
	
	//build content path
	if (pattern) {
		NSString *contentPattern = pattern;
		if ([contentPattern hasPrefix:@"/"]) {
			contentPattern = [contentPattern substringFromIndex:1];
		}
		if ([contentPattern hasSuffix:@"/"]) {
			contentPattern = [contentPattern substringToIndex:contentPattern.length - 1];
		}
		contentString = [self applyParameters:parameters
								   toTemplate:contentPattern];
	} else {
		fullPattern = @":prefix/:app_id";
	}
	
	//build full path using content path
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:DeeplinkBaseURLHostPathPrefix
																	 forKey:@":prefix"];
	if (self.appID) {
		params[@":app_id"] = self.appID;
	}
	
	if (contentString) {
		params[@":content"] = contentString;
	}
	
	return [self applyParameters:params
					  toTemplate:fullPattern];
}

- (NSString *)applyParameters:(NSDictionary *)parameters toTemplate:(NSString *)template {
	
	NSString *result = template.copy;
	
	for (NSString *name in parameters) {
		NSRange rangeOfName = [result rangeOfString:name];
		
		if (rangeOfName.location != NSNotFound) {
			result = [result stringByReplacingOccurrencesOfString:name
													   withString:parameters[name]
														  options:NSLiteralSearch
															range:rangeOfName];
		}
	}
	
	return result;
}

@end
