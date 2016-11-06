//
//  Deeplink.h
//  godtools
//
//  Created by Michael Harrison on 11/5/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DeeplinkLanguageCodeFormat) {
	DeeplinkLanguageCodeFormatISO639_3,
	DeeplinkLanguageCodeFormatBCP_47
};

@protocol DeeplinkGeneratorInternalInterface <NSObject>

@required
- (NSString *)appID;

@optional
- (NSString *)pathComponentsPattern;

@end

@protocol DeeplinkParserInternalInterface <NSObject>

@required
- (NSString *)appID;
- (instancetype)registerHandlers;

@end

@interface Deeplink : NSObject

#pragma mark - init

+ (instancetype)generate;
+ (instancetype)parser;

- (NSURL *)baseURLForApp;

- (instancetype)registerReferrerWithAppID:(NSString *)referrerAppID;
- (instancetype)registerReferrerWithAppID:(NSString *)referrerAppID referrerUserID:(NSString *)referrerUserID;
- (instancetype)build;
- (instancetype)open;

- (BOOL)openLaunchOptions:(NSDictionary *)launchOptions;
- (BOOL)openDeeplinkURL:(NSURL *)deeplinkURL;
- (BOOL)openDeeplinkHash:(NSDictionary *)deeplinkHash;

@end
