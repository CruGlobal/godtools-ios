//
//  Deeplink.h
//  godtools
//
//  Created by Michael Harrison on 11/5/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DeeplinkInternalInterface <NSObject>

@required
- (NSString *)appID;

@optional
- (NSString *)pathComponentsPattern;

@end

@interface Deeplink : NSObject

- (instancetype)registerReferrerWithAppID:(NSString *)referrerAppID;
- (instancetype)registerReferrerWithAppID:(NSString *)referrerAppID referrerUserID:(NSString *)referrerUserID;
- (instancetype)build;
- (instancetype)open;

@end
