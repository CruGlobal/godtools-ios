//
//  AFHTTPRequestSerializer+GTAPIHelpers.m
//  godtools
//
//  Created by Michael Harrison on 5/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "AFHTTPRequestSerializer+GTAPIHelpers.h"

#import <objc/runtime.h>
#import "GTLanguage+Helper.h"
#import "GTPackage+Helper.h"

NSString * const GTAPIEndpointAuthName			= @"auth";
NSString * const GTAPIEndpointMetaName			= @"meta";
NSString * const GTAPIEndpointPackagesName		= @"packages";
NSString * const GTAPIEndpointTranslationsName	= @"translations";
NSString * const GTAPIEndpointDraftsName        = @"drafts";

NSString * const GTAPIEndpointAuthParameterDeviceIDName				= @"device-id";

NSString * const GTAPIEndpointMetaParameterSinceName				= @"since";

NSString * const GTAPIEndpointPackagesParameterCompressedName		= @"compressed";
NSString * const GTAPIEndpointPackagesParameterCompressedValueTrue	= @"true";
NSString * const GTAPIEndpointPackagesParameterCompressedValueFalse	= @"false";
NSString * const GTAPIEndpointPackagesParameterVersionName			= @"version";

@implementation AFHTTPRequestSerializer (GTAPIHelpers)

- (NSURL *)baseURL {
	
#warning I feel dirty having used objc/runtime.h
	return objc_getAssociatedObject(self, @selector(baseURL));
}

- (void)setBaseURL:(NSURL *)baseURL {
	
	[self willChangeValueForKey:@"baseURL"];
	objc_setAssociatedObject(self, @selector(baseURL), baseURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"baseURL"];
	
}

- (NSMutableURLRequest *)authRequestWithAccessCode:(NSString *)accessCode deviceID:(NSString *)deviceID error:(NSError * __autoreleasing *)error {
	
	NSURL *fullURL					= [self.baseURL URLByAppendingPathComponent:GTAPIEndpointAuthName];
	fullURL							= (accessCode ? [fullURL URLByAppendingPathComponent:accessCode] : fullURL);
	NSDictionary *params			= (deviceID ? @{GTAPIEndpointAuthParameterDeviceIDName: deviceID} : @{} );
	
	NSMutableURLRequest *request	= [self requestWithMethod:@"POST"
												 URLString:[fullURL absoluteString]
												parameters:params
													 error:error];
	
	return request;
	
}

- (NSMutableURLRequest *)metaRequestWithLanguage:(GTLanguage *)language package:(GTPackage *)package since:(NSDate *)since error:(NSError *__autoreleasing *)error {

	NSURL *fullURL					= [self.baseURL URLByAppendingPathComponent:GTAPIEndpointMetaName];
	fullURL							= (language ? [fullURL URLByAppendingPathComponent:language.code] : fullURL);
	fullURL							= (package ? [fullURL URLByAppendingPathComponent:package.code] : fullURL);
	NSDictionary *params			= (since ? @{GTAPIEndpointMetaParameterSinceName: since} : @{} );

	NSMutableURLRequest *request	= [self requestWithMethod:@"GET"
												 URLString:[fullURL absoluteString]
												parameters:params
													 error:error];
	
	return request;
}

- (NSMutableURLRequest *)packageRequestWithLanguage:(GTLanguage *)language package:(GTPackage *)package version:(NSNumber *)version compressed:(BOOL)compressed error:(NSError * __autoreleasing *)error {
	
	NSParameterAssert(language.code);
	
	NSURL *fullURL					= [[self.baseURL URLByAppendingPathComponent:GTAPIEndpointPackagesName] URLByAppendingPathComponent:language.code];
	fullURL							= (package ? [fullURL URLByAppendingPathComponent:package.code] : fullURL);
	NSMutableDictionary	*params		= [NSMutableDictionary dictionary];
	params[GTAPIEndpointPackagesParameterCompressedName]	= (compressed ?
															   GTAPIEndpointPackagesParameterCompressedValueTrue :
															   GTAPIEndpointPackagesParameterCompressedValueFalse );
	
	if (version) {
		params[GTAPIEndpointPackagesParameterVersionName]	= version;
	}
	
	NSMutableURLRequest *request	= [self requestWithMethod:@"GET"
												 URLString:[fullURL absoluteString]
												parameters:params
													 error:error];
	
	return request;
}

- (NSMutableURLRequest *)translationRequestWithLanguage:(GTLanguage *)language package:(GTPackage *)package version:(NSNumber *)version compressed:(BOOL)compressed error:(NSError * __autoreleasing *)error {
	
	NSParameterAssert(language.code);
	
	NSURL *fullURL					= [[self.baseURL URLByAppendingPathComponent:GTAPIEndpointTranslationsName] URLByAppendingPathComponent:language.code];
	fullURL							= (package ? [fullURL URLByAppendingPathComponent:package.code] : fullURL);
	NSMutableDictionary	*params		= [NSMutableDictionary dictionary];
	params[GTAPIEndpointPackagesParameterCompressedName]	= (compressed ?
															   GTAPIEndpointPackagesParameterCompressedValueTrue :
															   GTAPIEndpointPackagesParameterCompressedValueFalse );
	
	if (version) {
		params[GTAPIEndpointPackagesParameterVersionName]	= version;
	}
	
	NSMutableURLRequest *request	= [self requestWithMethod:@"GET"
												 URLString:[fullURL absoluteString]
												parameters:params
													 error:error];
	
	return request;
}

- (NSMutableURLRequest *)draftsRequestWithLanguage:(GTLanguage *)language package:(GTPackage *)package version:(NSNumber *)version compressed:(BOOL)compressed error:(NSError * __autoreleasing *)error {
    
    NSParameterAssert(language.code);
    
    NSURL *fullURL					= [[self.baseURL URLByAppendingPathComponent:GTAPIEndpointDraftsName] URLByAppendingPathComponent:language.code];
    fullURL							= (package ? [fullURL URLByAppendingPathComponent:package.code] : fullURL);
    NSMutableDictionary	*params		= [NSMutableDictionary dictionary];
    params[GTAPIEndpointPackagesParameterCompressedName]	= (compressed ?
                                                               GTAPIEndpointPackagesParameterCompressedValueTrue :
                                                               GTAPIEndpointPackagesParameterCompressedValueFalse );
    
    if (version) {
        params[GTAPIEndpointPackagesParameterVersionName]	= version;
    }
    
    NSMutableURLRequest *request	= [self requestWithMethod:@"GET"
                                                 URLString:[fullURL absoluteString]
                                                parameters:params
                                                     error:error];
    
    return request;
}

@end
