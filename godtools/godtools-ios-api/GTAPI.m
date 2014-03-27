//
//  GTAPI.m
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTAPI.h"

#import "AFRaptureXMLRequestOperation.h"
#import "AFDownloadRequestOperation.h"

NSString * const GTAPIDefaultHeaderKeyAPIKey				= @"authorization";
NSString * const GTAPIDefaultHeaderKeyInterpreterVersion	= @"interpreter";

@interface GTAPI ()

@property (nonatomic, strong, readonly) NSString		*apiKey;
@property (nonatomic, strong, readonly) NSNumber		*interpreterVersion;

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
		
		[self willChangeValueForKey:@"errorHandler"];
		_errorHandler = errorHandler;
		[self didChangeValueForKey:@"errorHandler"];
		
		[self willChangeValueForKey:@"apiKey"];
		_apiKey	= config.apiKeyGodTools;
		[self didChangeValueForKey:@"apiKey"];
		
		[self willChangeValueForKey:@"interpreterVersion"];
		_interpreterVersion	= config.interpreterVersion;
		[self didChangeValueForKey:@"interpreterVersion"];
		
		[self.requestSerializer setValue:self.apiKey
					  forHTTPHeaderField:GTAPIDefaultHeaderKeyAPIKey];
		
		[self.requestSerializer setValue:[self.interpreterVersion stringValue]
					  forHTTPHeaderField:GTAPIDefaultHeaderKeyInterpreterVersion];
		
    }
	
    return self;
}

- (void)getMenuInfoSince:(NSDate *)date success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement))failure {
	
	NSDictionary *params			= (date ? @{@"since": date} : @{} );
	
	NSMutableURLRequest *request	= [self.requestSerializer requestWithMethod:@"GET"
																   URLString:[[NSURL URLWithString:@"meta" relativeToURL:self.baseURL] absoluteString]
																  parameters:params
																	   error:nil];
	
	AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request
																										 success:success
																										 failure:failure];
	
    [self.operationQueue addOperation:operation];
}

- (void)getResourcesForLanguage:(GTLanguage *)language progress:(void (^)(NSNumber *percentage))progress success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure {
	
	NSParameterAssert(language.code);
#warning untested implementation of getResourcesForLanguage
	
	NSDictionary *params			= @{@"language": language.code};
	
	NSMutableURLRequest *request	= [self.requestSerializer requestWithMethod:@"GET"
																   URLString:[[NSURL URLWithString:@"packages" relativeToURL:self.baseURL] absoluteString]
																  parameters:params
																	   error:nil];
	
	NSURL* documentsDirectory		= [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
																		inDomain:NSUserDomainMask
															   appropriateForURL:nil
																		  create:YES
																		   error:nil];
	NSURL *target					= [documentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", language.code]];
	
	AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request
																					 targetPath:[target absoluteString]
																				   shouldResume:YES];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		success(operation.request, operation.response, [NSURL URLWithString:responseObject]);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		failure(operation.request, operation.response, error);
		
	}];
	
	[operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
		
		progress(@(totalBytesReadForFile/(float)totalBytesExpectedToReadForFile));
		
	}];
	
	[self.operationQueue addOperation:operation];
	
}

@end
