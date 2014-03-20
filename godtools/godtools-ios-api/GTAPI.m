//
//  GTAPI.m
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTAPI.h"

#import "AFRaptureXMLRequestOperation.h"

NSString * const GTAPIBaseParamsAPIKeyKey = @"api_key";

@interface GTAPI ()

@property (nonatomic, strong, readonly) NSString		*apiKey;
@property (nonatomic, strong, readonly) NSDictionary	*baseParams;

@end

@implementation GTAPI

+ (instancetype)sharedAPI {
	
    static GTAPI *_sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		
        _sharedAPI = [[GTAPI alloc] initWithConfig:[GTConfig sharedConfig]];
		
    });
    
    return _sharedAPI;
}

- (instancetype)initWithConfig:(GTConfig *)config {
	
	self = [self initWithBaseURL:config.baseUrl];
	
    if (self) {
		
		[self willChangeValueForKey:@"apiKey"];
		_apiKey	= config.apiKeyGodTools;
		[self didChangeValueForKey:@"apiKey"];
		
    }
	
    return self;
}

- (NSDictionary *)baseParams {
	return @{ GTAPIBaseParamsAPIKeyKey: self.apiKey };
}

- (void)getMenuInfoSince:(NSDate *)date success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement))failure {
	
	NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
																   URLString:[[NSURL URLWithString:@"meta" relativeToURL:self.baseURL] absoluteString]
																  parameters:self.baseParams
																	   error:nil];
	
	AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request
																										 success:success
																										 failure:failure];
	
    [self.operationQueue addOperation:operation];
}

- (void)getResourcesForLanguage:(GTLanguage *)language since:(NSDate *)date success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement))failure {
	
	
	
}

@end
