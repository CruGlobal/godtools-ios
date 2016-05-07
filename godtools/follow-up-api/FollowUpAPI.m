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
    
    
    [self POST:@"subscribers"
    parameters:[self parametersFromSubscriber:subscriber]
       success:successBlock
       failure:failureBlock];
}

- (NSDictionary *)parametersFromSubscriber:(GTFollowUpSubscription *) subscriber {
    NSArray *nameParts = subscriber.name ? [subscriber.name componentsSeparatedByString:@" "] : [[NSArray alloc] init];
    
    // if the single name field is split into more that three parts, combine the parts [1,n] into last name field.
    // if the single name field is split into to parts, put the part [1] in last name field.
    // part [0] will always be in the first name field by itself.
    NSString *lastName = nameParts.count > 1 ?
        (nameParts.count > 2 ?
            [[nameParts subarrayWithRange:NSMakeRange(1, nameParts.count - 1)] componentsJoinedByString: @" "]
            : nameParts[1])
        : @"";
    
    return @{@"subscriber[route_id]" : [GTConfig sharedConfig].followUpApiDefaultRouteId,
                                 @"subscriber[language_code]" : subscriber.languageCode ?: @"",
                                 @"subscriber[email]" : subscriber.emailAddress ?: @"",
                                 @"subscriber[first_name]" : nameParts[0] ?: @"",
                                 @"subscriber[last_name]" : lastName};
    
}
@end