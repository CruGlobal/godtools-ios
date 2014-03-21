//
//  GTAPI.m
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTAPI.h"

#import "AFRaptureXMLRequestOperation.h"

NSString * const GTAPIBaseParamsAPIKeyKey				= @"api_key";
NSString * const GTAPIBaseParamsInterpreterVersionKey	= @"interpreter_version";

@interface GTAPI ()

@property (nonatomic, strong, readonly) NSString		*apiKey;
@property (nonatomic, strong, readonly) NSNumber		*interpreterVersion;
@property (nonatomic, strong, readonly) NSDictionary	*baseParams;

@end

@implementation GTAPI

+ (instancetype)sharedAPI {
	
    static GTAPI *_sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		
        _sharedAPI = [[GTAPI alloc] initWithConfig:[GTConfig sharedConfig] errorHandler:[GTAPIErrorHandler sharedErrorHandler]];
		
    });
    
    return _sharedAPI;
}

- (instancetype)initWithConfig:(GTConfig *)config errorHandler:(GTAPIErrorHandler *)errorHandler {
	
	self = [self initWithBaseURL:config.baseUrl];
	
    if (self) {
		
		[self willChangeValueForKey:@"apiKey"];
		_apiKey	= config.apiKeyGodTools;
		[self didChangeValueForKey:@"apiKey"];
		
		[self willChangeValueForKey:@"errorHandler"];
		_errorHandler = errorHandler;
		[self didChangeValueForKey:@"errorHandler"];
		
		[self willChangeValueForKey:@"interpreterVersion"];
		_interpreterVersion	= config.interpreterVersion;
		[self didChangeValueForKey:@"interpreterVersion"];
		
    }
	
    return self;
}

- (NSDictionary *)baseParams {
	return @{ GTAPIBaseParamsAPIKeyKey: self.apiKey , GTAPIBaseParamsInterpreterVersionKey: self.interpreterVersion };
}

- (void)getMenuInfoSince:(NSDate *)date success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement))failure {
	
	NSMutableDictionary *params = (date ? [NSMutableDictionary dictionaryWithDictionary:@{@"since": date}] : [NSMutableDictionary dictionary] );
	[params addEntriesFromDictionary:self.baseParams];
	
	NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
																   URLString:[[NSURL URLWithString:@"meta" relativeToURL:self.baseURL] absoluteString]
																  parameters:params
																	   error:nil];
	
	AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request
																										 success:success
																										 failure:failure];
	
    [self.operationQueue addOperation:operation];
}

- (void)getResourcesForLanguage:(GTLanguage *)language since:(NSDate *)date success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement))failure {
	
	
	
}

@end
