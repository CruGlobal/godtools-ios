//
//  FollowUpAPI.h
//  godtools
//
//  Created by Ryan Carlson on 4/4/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

#import "GTConfig.h"

#import "GTFollowUpSubscription.h"

@interface FollowUpAPI : AFHTTPRequestOperationManager

+ (instancetype)sharedAPI;

- (instancetype)initWithConfig:(GTConfig *)config;

- (BOOL)isReachable;

- (void)sendNewSubscription:(GTFollowUpSubscription *)subscriber;
- (void)sendNewSubscription:(GTFollowUpSubscription *)subscriber onSuccess:(void (^)(AFHTTPRequestOperation *, id))successBlock onFailure:(void (^)(AFHTTPRequestOperation *, NSError *)) failureBlock;
@end