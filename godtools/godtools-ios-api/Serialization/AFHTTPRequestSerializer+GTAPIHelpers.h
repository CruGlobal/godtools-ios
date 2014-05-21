//
//  AFHTTPRequestSerializer+GTAPIHelpers.h
//  godtools
//
//  Created by Michael Harrison on 5/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "AFURLRequestSerialization.h"

@class GTLanguage, GTPackage;

@interface AFHTTPRequestSerializer (GTAPIHelpers)

@property (nonatomic, strong) NSURL *baseURL;

- (NSMutableURLRequest *)metaRequestWithLanguage:(GTLanguage *)language
										 package:(GTPackage *)package
										   since:(NSDate *)since
										   error:(NSError * __autoreleasing *)error;

- (NSMutableURLRequest *)packageRequestWithLanguage:(GTLanguage *)language
											package:(GTPackage *)package
											version:(NSNumber *)version
										 compressed:(BOOL)compressed
											  error:(NSError * __autoreleasing *)error;

- (NSMutableURLRequest *)translationRequestWithLanguage:(GTLanguage *)language
											package:(GTPackage *)package
											version:(NSNumber *)version
										 compressed:(BOOL)compressed
											  error:(NSError * __autoreleasing *)error;

@end
