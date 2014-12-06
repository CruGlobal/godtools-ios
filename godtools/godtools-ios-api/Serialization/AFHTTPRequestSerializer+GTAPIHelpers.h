//
//  AFHTTPRequestSerializer+GTAPIHelpers.h
//  godtools
//
//  Created by Michael Harrison on 5/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "AFURLRequestSerialization.h"

@class GTLanguage, GTPackage;

/**
 *  A set of Helper functions that Serialize requests to the GodTools API.
 *  For more information the API is documented here https://github.com/CruGlobal/godtools-api/wiki
 */
@interface AFHTTPRequestSerializer (GTAPIHelpers)

/**
 *  Base URL for GodTools API. Used to generate requests in the following helper methods.
 *
 *	@example [NSURL URLWithString:@"http://godtoolsapp.com/api/v1/"]
 *
 *  @warning needs to be set before using the following helper methods.
 */
@property (nonatomic, strong) NSURL *baseURL;


/**
 *  Configures a request object for an Auth request. If you send this request and it is successful you will receive
 *  an Auth Token that can be set as a header in future requests and give you permission to download resources
 *  and meta data.
 *
 *  @param accessCode The API access code. This is currently your API key.
 *  @param deviceID   Unique identifier for the device. It is Optional. If used we recommend using the Identifier for vendor.
 *  @param error      If an error occurs in create the request object the details will be found in this object.
 *
 *  @return a NSMutableURLRequest object that has been configured for a POST request to the Auth endpoint.
 */
- (NSMutableURLRequest *)authRequestWithAccessCode:(NSString *)accessCode
										  deviceID:(NSString *)deviceID
											 error:(NSError * __autoreleasing *)error;

/**
 *  Configures a request for a Meta data request. If you send this request and it is successful you will receive
 *  an xml response that lists the meta data for available resources. See docs for examples. It will filter out resources using the language,
 *  package and since date as filters where you have provided them.
 *
 *  @param language Optional. GTLanguage object to filter the response list. eg if language.code = @"en" then only english resources will be listed in the response. package and since can be nil when passing in a language object.
 *  @param package  Optional. GTPackage object to filter the response list. If you set pass in a package object you have to pass a language object or you will receive an error.
 *  @param since    Optional. NSDate object that represents the time since you last asked for this information. This ensures you will only get a list of new data. Data that hasn't been updated since this date will be filtered out. Since does not depend on language or package.
 *  @param error    If an error occurs in create the request object the details will be found in this object.
 *
 *  @return a NSMutableURLRequest object that has been configured for a GET request to the Meta endpoint.
 */
- (NSMutableURLRequest *)metaRequestWithLanguage:(GTLanguage *)language
										 package:(GTPackage *)package
										   since:(NSDate *)since
										   error:(NSError * __autoreleasing *)error;

/**
 *  Configures a request for all assets associated with the your package, language, version combo.
 *
 *  @param language   Required. Represents the language you want your resources in. If this is the only object passed in you will receive all resources in this language.
 *  @param package    Optional. Represents the package you want in the language set. You must pass a language with your package object or you will receive an error.
 *  @param version    Optional. Represents the version of the package you would like. Language and Package must be sent with version or you will receive an error. If version is absent you will receive the lastest version of the package(s)
 *  @param compressed Required. We always recommend compressed for iOS. This determines whether you receive a compressed file with all assets for you filters or whether you get an xml response with references to the config files for each resource. If you select uncompressed you would then need to get each asset one by one. This allows for 'streaming' of resources instead of downloading everything at once. That is not God Tools approach at the moment but would be a good approach for another client or as a future option in God Tools.
 *  @param error      If an error occurs in create the request object the details will be found in this object.
 *
 *  @return a NSMutableURLRequest object that has been configured for a GET request to the Packages endpoint.
 */
- (NSMutableURLRequest *)packageRequestWithLanguage:(GTLanguage *)language
											package:(GTPackage *)package
											version:(NSNumber *)version
										 compressed:(BOOL)compressed
											  error:(NSError * __autoreleasing *)error;

/**
 *  Configures a request for all xml files associated with the your package, language, version combo.
 *
 *  @param language   Required. Represents the language you want your resources in. If this is the only object passed in you will receive all resources in this language.
 *  @param package    Optional. Represents the package you want in the language set. You must pass a language with your package object or you will receive an error.
 *  @param version    Optional. Represents the version of the package you would like. Language and Package must be sent with version or you will receive an error. If version is absent you will receive the lastest version of the package(s)
 *  @param compressed Required. We always recommend compressed for iOS. This determines whether you receive a compressed file with all assets for you filters or whether you get an xml response with references to the config files for each resource. If you select uncompressed you would then need to get each asset one by one. This allows for 'streaming' of resources instead of downloading everything at once. That is not God Tools approach at the moment but would be a good approach for another client or as a future option in God Tools.
 *  @param error      If an error occurs in create the request object the details will be found in this object.
 *
 *  @return a NSMutableURLRequest object that has been configured for a GET request to the Translation endpoint.
 */
- (NSMutableURLRequest *)translationRequestWithLanguage:(GTLanguage *)language
											package:(GTPackage *)package
											version:(NSNumber *)version
										 compressed:(BOOL)compressed
											  error:(NSError * __autoreleasing *)error;


- (NSMutableURLRequest *)draftsRequestWithLanguage:(GTLanguage *)language package:(GTPackage *)package version:(NSNumber *)version compressed:(BOOL)compressed error:(NSError * __autoreleasing *)error;

- (NSMutableURLRequest *)pageRequestWithLanguage:(GTLanguage *)language package:(GTPackage *)package pageID:(NSString *)pageID error:(NSError * __autoreleasing *)error;

- (NSMutableURLRequest *)createDraftsRequestWithLanguage:(GTLanguage *)language package:(GTPackage *)package error:(NSError * __autoreleasing *)error;

@end
