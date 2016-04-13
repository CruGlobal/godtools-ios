//
//  FollowUpAPI.m
//  godtools
//
//  Created by Ryan Carlson on 4/4/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FollowUpAPI.h"
#import "AFURLResponseSerialization.h"

@interface FollowUpAPI()


@end

@implementation FollowUpAPI

+ (instancetype)sharedAPI {
    static FollowUpAPI *_sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        _sharedAPI = [[FollowUpAPI alloc] initWithConfig:[GTConfig sharedConfig]];
    });
    
    return _sharedAPI;
}


- (instancetype)initWithConfig:(GTConfig *)config {
    self = [self initWithBaseURL:config.followUpApiUrl];
    
    [self.requestSerializer setValue:config.followUpApiSharedKey
                  forHTTPHeaderField:@"Access-Id"];
    
    [self.requestSerializer setValue:config.followUpApiSecretKey
                  forHTTPHeaderField:@"Access-Secret"];
    
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded"
                  forHTTPHeaderField:@"Content-Type"];
    
    self.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:config.followUpApiUrl.host];
    [self.reachabilityManager startMonitoring];
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return self;
}


- (BOOL) isReachable {
    return self.reachabilityManager.isReachable;
}


- (void)sendNewSubscription:(GTFollowUpSubscription *)subscriber {
    // validate email is present
    
    [self sendNewSubscription:subscriber
                    onSuccess:nil
                    onFailure:nil];
}

- (void)sendNewSubscription:(GTFollowUpSubscription *)subscriber onSuccess:(void (^)(AFHTTPRequestOperation *, id))successBlock onFailure:(void (^)(AFHTTPRequestOperation *, NSError *)) failureBlock {
    
    NSDictionary *parameters = @{@"route_id" : [GTConfig sharedConfig].followUpApiDefaultRouteId,
                                 @"language_code" : subscriber.languageCode,
                                 @"email" : subscriber.emailAddress};
    
    [self POST:@"subscribers"
    parameters:parameters
       success:successBlock
       failure:failureBlock];
}

@end