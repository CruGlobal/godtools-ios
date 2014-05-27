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
#import "GTAPIErrorHandler.h"

@interface GTAPI : AFHTTPRequestOperationManager

@property (nonatomic, strong)			NSString *authToken;
@property (nonatomic, strong, readonly) GTAPIErrorHandler *errorHandler;

+ (instancetype)sharedAPI;
- (instancetype)initWithConfig:(GTConfig *)config errorHandler:(GTAPIErrorHandler *)errorHandler;

- (void)getAuthTokenForDeviceID:(NSString *)deviceID
						success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSString *authToken))success
						failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)getMenuInfoSince:(NSDate *)date
				 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement))success
				 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement))failure;

- (void)getResourcesForLanguage:(GTLanguage *)language
					   progress:(void (^)(NSNumber *percentage))progress
						success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath))success
						failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

@end
