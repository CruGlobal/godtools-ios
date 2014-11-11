//
//  GTAPI.m
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTAPI.h"

#import "AFHTTPRequestSerializer+GTAPIHelpers.h"
#import "AFRaptureXMLRequestOperation.h"
#import "AFDownloadRequestOperation.h"
#import "RXMLElement.h"
#import <GTViewController/GTFileLoader.h>

NSString * const GTAPIDefaultHeaderKeyAPIKey				= @"authorization";
NSString * const GTAPIDefaultHeaderKeyInterpreterVersion	= @"interpreter";
NSString * const GTAPIDefaultHeaderKeyDensity				= @"density";
NSString * const GTAPIDefaultHeaderValueDensity				= @"high";

NSString * const GTAPIAuthEndpointAuthTokenKey				= @"auth-token";

@interface GTAPI ()

@property (nonatomic, strong, readonly) NSString		*apiKey;
@property (nonatomic, strong, readonly) NSNumber		*interpreterVersion;

- (void)getFilesForRequest:(NSMutableURLRequest *)request progress:(void (^)(NSNumber *))progress success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSURL *))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure;

@end

@implementation GTAPI

#pragma mark - initialization

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
		_errorHandler		= errorHandler;
		[self didChangeValueForKey:@"errorHandler"];
		
		[self willChangeValueForKey:@"apiKey"];
		_apiKey				= config.apiKeyGodTools;
		[self didChangeValueForKey:@"apiKey"];
		
		[self willChangeValueForKey:@"interpreterVersion"];
		_interpreterVersion	= config.interpreterVersion;
		[self didChangeValueForKey:@"interpreterVersion"];
		
		self.requestSerializer.baseURL	= self.baseURL;
		
        
        
		[self.requestSerializer setValue:self.apiKey
					  forHTTPHeaderField:GTAPIDefaultHeaderKeyAPIKey];
        
		[self.requestSerializer setValue:[self.interpreterVersion stringValue]
					  forHTTPHeaderField:GTAPIDefaultHeaderKeyInterpreterVersion];
        
		[self.requestSerializer setValue:GTAPIDefaultHeaderValueDensity
					  forHTTPHeaderField:GTAPIDefaultHeaderKeyDensity];
		
    }
	
    return self;
}

#pragma mark - getters setters

- (void)setAuthToken:(NSString *)authToken {
	
	[self willChangeValueForKey:@"authToken"];
	_authToken	= authToken;
	[self didChangeValueForKey:@"authToken"];
	
	[self.requestSerializer setValue:_authToken
				  forHTTPHeaderField:GTAPIDefaultHeaderKeyAPIKey];
	
}

#pragma mark - Authorization methods

- (void)getAuthTokenForDeviceID:(NSString *)deviceID success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSString *authToken))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure {
	
	NSMutableURLRequest *request			= [self.requestSerializer authRequestWithAccessCode:self.apiKey
																			  deviceID:deviceID
																				 error:nil];
	
	AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request
																				success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
                                                                                    NSLog(@"get auth successful");
																					success(request, response, [XMLElement child:GTAPIAuthEndpointAuthTokenKey].text);
																					
																				}
																				failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {
                                                                                    NSLog(@"get auth not successful");
																					failure(request, response, error);
																					
																				}];
	
	[self.operationQueue addOperation:operation];
}

#pragma mark - download meta information methods

- (void)getMenuInfoSince:(NSDate *)date success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement))failure {
	
	NSMutableURLRequest *request			= [self.requestSerializer metaRequestWithLanguage:nil
																				   package:nil
																					 since:date
																					 error:nil];
	
    
	AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request
																										 success:success
																										 failure:failure];
	
    [self.operationQueue addOperation:operation];
}

#pragma mark - download resource methods

- (void)getResourcesForLanguage:(GTLanguage *)language progress:(void (^)(NSNumber *percentage))progress success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure {
	
	NSParameterAssert(language.code);
	
	NSMutableURLRequest *request	= [self.requestSerializer packageRequestWithLanguage:language
																			  package:nil
																			  version:nil
																		   compressed:YES
																				error:nil];
	
	[self getFilesForRequest:request progress:progress success:success failure:failure];
}

- (void)getXmlFilesForLanguage:(GTLanguage *)language progress:(void (^)(NSNumber *))progress success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSURL *))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure {
	
	NSParameterAssert(language.code);
	
	NSMutableURLRequest *request	= [self.requestSerializer translationRequestWithLanguage:language
																			  package:nil
																			  version:nil
																		   compressed:YES
																				error:nil];
	
	[self getFilesForRequest:request progress:progress success:success failure:failure];
}

- (void)getFilesForRequest:(NSMutableURLRequest *)request progress:(void (^)(NSNumber *))progress success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSURL *))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure {
    NSLog(@"===========get files for request");
	NSURL* documentsDirectory		= [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
																		inDomain:NSUserDomainMask
															   appropriateForURL:nil
																		  create:YES
																		   error:nil];
	
	//target will have the format ${DOCUMENTS_PATH}/1E2DFA89-496A-47FD-9941-DF1FC4E6484A.zip where the filename is a unique identifier for this download.
	NSURL *target					= [documentsDirectory URLByAppendingPathComponent:[[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"zip"]];
	
    NSLog(@"target: %@",target);
    
	AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request
																					 targetPath:[target absoluteString]
																				   shouldResume:YES];
    NSLog(@"download operation defined");
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		success(operation.request, operation.response, [NSURL URLWithString:responseObject]);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		failure(operation.request, operation.response, error);
		
	}];
	
	[operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
		
		progress(@(totalBytesReadForFile/(float)totalBytesExpectedToReadForFile));
		
	}];
    
    
	
	[self.operationQueue addOperation:operation];
	
#warning untested implementation of getFilesForLanguage
	
}

@end
