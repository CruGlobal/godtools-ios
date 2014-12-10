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

/**
 *  Class for making requests to the God Tools API using convenient methods
 */
@interface GTAPI : AFHTTPRequestOperationManager

/**
 *  This is the token required by all requests to the God Tools API. You retreive it by calling getAuthTokenForDeviceID:success:failure:
 */
@property (nonatomic, strong)			NSString *authToken;

/**
 *  error handler is required for displaying errors that happen during the request, on the server and in processing the response.
 */
@property (nonatomic, strong, readonly) GTAPIErrorHandler *errorHandler;

/**
 *  Returns the Singleton instance of this class
 *
 *  @return singleton
 */
+ (instancetype)sharedAPI;

/**
 *  This is the required initializer. It takes a config object to set all API keys and header values. It also takes an error handler
 *  so that errors can be processed differently based on context.
 *
 *  @param config       holds the API keys and header values needed to setup the API Class.
 *  @param errorHandler designed to process and display errors.
 *
 *  @return an initalized instance of this class
 */
- (instancetype)initWithConfig:(GTConfig *)config errorHandler:(GTAPIErrorHandler *)errorHandler;

/**
 *  Retrieves an Auth Token from the APIs auth endpoint. This token is needed for all future calls to the API.
 *  To have it automatically sent with all future calls assign the value to the authToken property of this class.
 *
 *  @warning you should wait for this method to return the auth token before making other requests to the API.
 *
 *  @param deviceID A string that uniquely identifies the current device. It's optional. We recommend using the Identifier for vendor.
 *  @param success  callback that delivers your auth token
 *  @param failure  callback that delivers the error object describing why your request failed.
 *
 *  @example [api getAuthTokenForDeviceID:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSString *authToken) {
                                      api.authToken = authToken;
								  }
                                  failure:nil];
 *
 */
- (void)getAuthTokenForDeviceID:(NSString *)deviceID
						success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSString *authToken))success
						failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

/**
 *  Retrieves response from the APIs auth endpoint together with an access code. This token is needed for all future calls to the API.
 *  To have it automatically sent with all future calls assign the value to the authToken property of this class.
 *
 *  @warning you should wait for this method to return the auth token before making other requests to the API.
 *
 *  @param accessCode A string that will be used as an access code for translator mode.
 *  @param success  callback that delivers your auth token to be taken from the response headers
 *  @param failure  callback that delivers the error object describing why your request failed.
 *
 *  @example [api getAuthTokenWithAccessCode:accessCode
 success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSString *authToken) {
 api.authToken = authToken;
 }
 failure:nil];
 *
 */

- (void)getAuthTokenWithAccessCode:(NSString *)accessCode success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSString *authToken))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;
/**
 *  If you send this request and it is successful you will receive an xml response that lists the meta data for available resources.
 *  See docs for examples. It will filter out resources using the language, package and since date as filters where you have provided them.
 *
 *  @param date    The date of your last request to this endpoint. Entries that haven't been updated since then will be filtered out. Optional.
 *  @param success callback that delivers the xml object that contains the meta data. Currently this is an RXMLElement object. This may change but for now you should include that header if you want to use the result.
 *  @param failure callback that delivers the error object describing why your request failed.
 */
- (void)getMenuInfoSince:(NSDate *)date
				 success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement))success
				 failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement))failure;

/**
 *  Retrieves all files for all resources associated with the language passed to this method.
 *
 *  @warning will throw exception if language.code is nil
 *
 *  @param language the language you would like to download resources for.
 *  @param progress callback used to display the download progress for this request
 *  @param success  callback for processing a successful request. In addition to the request and response you will get the path where the files have been downloaded to.
 *  @param failure  callback that delivers the error object describing why your request failed.
 */
- (void)getResourcesForLanguage:(GTLanguage *)language
					   progress:(void (^)(NSNumber *percentage))progress
						success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath))success
						failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

/**
 *  Retrieves only the xml files for all resources associated with the language passed to this method. This should be used to update a resource.
 *  @note getResourcesForLanguage:progress:success:failure: should be used when the major version number increases (eg version-number-on-device = 3.2 version-number-in-meta-data = 4.0)
 *
 *  getXmlFilesForLanguage:progress:success:failure: should be used when the minor version number increases (eg version-number-on-device = 3.2 version-number-in-meta-data = 3.3)
 *
 *  @warning will throw exception if language.code is nil
 *
 *  @param language the language you would like to download resources for.
 *  @param progress callback used to display the download progress for this request
 *  @param success  callback for processing a successful request. In addition to the request and response you will get the path where the files have been downloaded to.
 *  @param failure  callback that delivers the error object describing why your request failed.
 */
- (void)getXmlFilesForLanguage:(GTLanguage *)language
					   progress:(void (^)(NSNumber *percentage))progress
						success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath))success
						failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)getDraftsResourcesForLanguage:(GTLanguage *)language progress:(void (^)(NSNumber *percentage))progress success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

-(void)createDraftsForLanguage:(GTLanguage *)language package:(GTPackage *)package success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)getPageForLanguage:(GTLanguage *)language package:(GTPackage*)package pageID:(NSString *)pageID progress:(void (^)(NSNumber *percentage))progress success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response,NSURL *targetPath))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

-(void)publishTranslationForLanguage:(GTLanguage *)language package:(GTPackage *)package success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;


@end
