//
//  GTAPIStub.m
//  godtools
//
//  Created by Michael Harrison on 5/20/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import "GTAPIStub.h"
#import "RXMLElement.h"

@implementation GTAPIStub

- (void)getMenuInfoSince:(NSDate *)date success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure {
	
	RXMLElement *rootElement = [RXMLElement elementFromXMLFilename:@"GTAPIMetaDataResponse" fileExtension:@"xml"];
	
	success(nil, nil, rootElement);
	
}

@end
