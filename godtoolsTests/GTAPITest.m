//
//  GTAPITest.m
//  godtools
//
//  Created by Michael Harrison on 3/19/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GTAPI.h"

@interface GTAPITest : XCTestCase

@property (nonatomic, strong) GTAPI *api;

@end

@implementation GTAPITest

- (void)setUp {
	
	self.api = [GTAPI sharedAPI];
	
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	
	self.api = nil;
	
    [super tearDown];
}

- (void)testThatTheAPICanDownloadAnXmlFileFromTheMetaEndpoint {
    
	[self.api getMenuInfoSince:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, id XMLRootElement) {
		NSLog(@"%@", XMLRootElement);
		XCTAssertNotNil(XMLRootElement, @"XML root element is nil");
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id XMLRootElement) {
		XCTFail(@"Recieved failure from meta endpoint with message: %@", error.localizedDescription);
	}];
	
}

@end
