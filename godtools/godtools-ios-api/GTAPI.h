//
//  GTAPI.h
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "GTLanguage+Helper.h"
#import "GTConfig.h"

@interface GTAPI : AFHTTPRequestOperationManager

+ (instancetype)sharedAPI;
- (instancetype)initWithConfig:(GTConfig *)config;

- (void)getMenuInfoSince:(NSDate *)date success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement))failure;
- (void)getResourcesForLanguage:(GTLanguage *)language since:(NSDate *)date success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement))failure;

@end
