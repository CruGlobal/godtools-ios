//
//  GTAPI.m
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Modified by Lee Braddock.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTAPI.h"

#import "AFHTTPRequestSerializer+GTAPIHelpers.h"
#import "AFRaptureXMLRequestOperation.h"
#import "AFDownloadRequestOperation.h"
#import "RXMLElement.h"
#import "GTDefaults.h"
#import <GTViewController/GTFileLoader.h>

NSString * const GTAPIDefaultHeaderKeyAPIKey				= @"authorization";
NSString * const GTAPIDefaultHeaderKeyInterpreterVersion	= @"interpreter";
NSString * const GTAPIDefaultHeaderKeyDensity				= @"density";
NSString * const GTAPIDefaultHeaderValueDensity				= @"high";

NSString * const GTAPIAuthEndpointAuthTokenKey				= @"auth-token";

@interface GTAPI ()
/**
 *  This is the token required by all requests to the God Tools API. You retreive it by calling getAuthTokenForDeviceID:success:failure:
 */
@property (nonatomic, strong)			NSString		*authToken;
@property (nonatomic, strong, readonly) NSString		*apiKey;
@property (nonatomic, strong, readonly) NSNumber		*interpreterVersion;
@property (nonatomic, strong) AFDownloadRequestOperation *languageAFDownloadRequestOperation;

- (AFDownloadRequestOperation *)getFilesForRequest:(NSMutableURLRequest *)request progress:(void (^)(NSNumber *))progress success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSURL *))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure;
- (void)startRequestWithOperation:(NSOperation *)apiRequestOperation;

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
        _apiKey				= [[GTDefaults sharedDefaults] genericApiToken];
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
	
	if (self.authToken) {
		
		success(nil, nil, self.authToken);
		
	} else {
	
		NSMutableURLRequest *request			= [self.requestSerializer authRequestWithAccessCode:nil
																				  deviceID:deviceID
																					 error:nil];
		
		__weak typeof(self)weakSelf = self;
		AFRaptureXMLRequestOperation *operation = [AFRaptureXMLRequestOperation XMLParserRequestOperationWithRequest:request
																					success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement) {
																						
																						weakSelf.authToken = [[response allHeaderFields] valueForKey:@"Authorization"];
																						success(request, response, weakSelf.authToken);
																						
																					} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement) {

																						failure(request, response, error);
																						
																					}];
		
		[self.operationQueue addOperation:operation];
			
	}
	
}

- (void)getAuthTokenWithAccessCode:(NSString *)accessCode success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response,NSString *authToken))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure {
    
    NSMutableURLRequest *request			= [self.requestSerializer authRequestWithAccessCode:accessCode
                                                                              deviceID:nil
                                                                                 error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
	
	__weak typeof(self)weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		weakSelf.authToken = [operation.response.allHeaderFields objectForKey:@"Authorization"];
        success(operation.request, operation.response, weakSelf.authToken);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation.request, operation.response, error);
    }];
    
    [self startRequestWithOperation:operation];
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
	
    [self startRequestWithOperation:operation];
}

#pragma mark - download resource methods

- (void)cancelGetResourcesForLanguage {
    [self.languageAFDownloadRequestOperation cancel];
}

- (void)getResourcesForLanguage:(GTLanguage *)language progress:(void (^)(NSNumber *percentage))progress success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure {
	
	NSParameterAssert(language.code);
	
	NSMutableURLRequest *request	= [self.requestSerializer packageRequestWithLanguage:language
																			  package:nil
																			  version:nil
																		   compressed:YES
																				error:nil];
	
	self.languageAFDownloadRequestOperation = [self getFilesForRequest:request progress:progress success:success failure:failure];
}

- (void)getXmlFilesForLanguage:(GTLanguage *)language progress:(void (^)(NSNumber *percentage))progress success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure {
	
	NSParameterAssert(language.code);
	
	NSMutableURLRequest *request	= [self.requestSerializer translationRequestWithLanguage:language
																			  package:nil
																			  version:nil
																		   compressed:YES
																				error:nil];
	
	[self getFilesForRequest:request progress:progress success:success failure:failure];
}

- (AFDownloadRequestOperation *)getFilesForRequest:(NSMutableURLRequest *)request progress:(void (^)(NSNumber *))progress success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSURL *))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure {

	/*NSURL* documentsDirectory		= [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
																		inDomain:NSUserDomainMask
															   appropriateForURL:nil
																		  create:YES
																		   error:nil];*/
    
	//target will have the format ${DOCUMENTS_PATH}/1E2DFA89-496A-47FD-9941-DF1FC4E6484A.zip where the filename is a unique identifier for this download.
	//NSURL *target					= [documentsDirectory URLByAppendingPathComponent:[[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"zip"]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *target = [[paths objectAtIndex:0] stringByAppendingPathComponent:[ [ [NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"zip" ]];
    
	AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request
                                                                                    targetPath:target
																				   shouldResume:YES];

	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		success(operation.request, operation.response, [NSURL URLWithString:responseObject]);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failure(operation.request, operation.response, error);
		
	}];
	
	[operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {

        NSNumber *percentage = @(totalBytesReadForFile/(float)totalBytesExpectedToReadForFile);
		progress(percentage);
		
	}];

	[self startRequestWithOperation:operation];
	
    return operation;
}

#pragma mark - Drafts
- (void)getDraftsResourcesForLanguage:(GTLanguage *)language progress:(void (^)(NSNumber *percentage))progress success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure {
    NSParameterAssert(language.code);
    
    NSMutableURLRequest *request	= [self.requestSerializer draftsRequestWithLanguage:language
                                                                             package:nil
                                                                             version:nil
                                                                          compressed:YES
                                                                               error:nil];
    
    [self getFilesForRequest:request progress:progress success:success failure:failure];
}

-(void)getPageForLanguage:(GTLanguage *)language package:(GTPackage *)package pageID:(NSString *)pageID progress:(void (^)(NSNumber *))progress success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure{
    NSParameterAssert(language.code);
	
    NSMutableURLRequest *request	= [self.requestSerializer pageRequestWithLanguage:language
                                                                           package:package
                                                                            pageID:pageID
                                                                             error:nil];
    
    [self getFilesForRequest:request progress:progress success:success failure:failure];
    
}

-(void)createDraftsForLanguage:(GTLanguage *)language package:(GTPackage *)package success:(void (^)(NSURLRequest *, NSHTTPURLResponse *))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure{
    
    NSMutableURLRequest *request	= [self.requestSerializer createDraftsRequestWithLanguage:language
                                                                                   package:package
                                                                                     error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation.request, operation.response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation.request, operation.response, error);
    }];
    
    [self startRequestWithOperation:operation];

}

-(void)publishTranslationForLanguage:(GTLanguage *)language package:(GTPackage *)package success:(void (^)(NSURLRequest *, NSHTTPURLResponse *))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure{
    
    NSMutableURLRequest *request = [self.requestSerializer publishDraftRequestWithLanguage:language package:package error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation.request, operation.response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation.request, operation.response, error);
    }];
    
    [self startRequestWithOperation:operation];
}

- (void)startRequestWithOperation:(NSOperation *)apiRequestOperation {
	
	__weak typeof(self)weakSelf = self;
	[self getAuthTokenForDeviceID:nil
						  success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSString *authToken) {
							  
							  [weakSelf.operationQueue addOperation:apiRequestOperation];
							  
						  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
							  
							  [weakSelf.operationQueue addOperation:apiRequestOperation];
							  
						  }];
	
}


@end
