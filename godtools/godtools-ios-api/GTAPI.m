//
//  GTAPI.m
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTAPI.h"

@interface GTAPI ()

@property (nonatomic, strong) GTDataImporter *dataImporter;

@end

@implementation GTAPI

+ (instancetype)api {
	
	static GTAPI *api;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		
		
		
	});
	
	return api;
	
}

- (instancetype)initWithConfig:(GTConfig *)config {
	
	
	
}

- (void)getMenuInfoSince:(NSDate *)date success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement))failure;{
	
}

- (void)getResourcesForLanguage:(GTLanguage *)language since:(NSDate *)date success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLElement))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLElement))failure;

@end
