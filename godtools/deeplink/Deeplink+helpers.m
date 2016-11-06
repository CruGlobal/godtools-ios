//
//  Deeplink+helpers.m
//  godtools
//
//  Created by Michael Harrison on 11/5/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import "Deeplink.h"
#import "Deeplink+helpers.h"
#import <JLRoutes/JLRoutes.h>

@implementation Deeplink (helpers)

@dynamic params;
@dynamic pathComponents;
@dynamic pathComponentPattern;

- (instancetype)addParamWithName:(NSString *)name
						   value:(NSString *)value {
	
	if (!name || !value) {
		return self;
	}
	
	self.params[name] = value;
	
	return self;
}

- (instancetype)addPathComponentWithName:(NSString *)name
								   value:(NSString *)value {
	
	if (!name || !value) {
		return self;
	}
	
	self.pathComponents[name] = value;
	
	return self;
}

- (instancetype)addRoutePath:(NSString *)routePath
					 handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock {
	
	NSString *fullRoutePath = [self.baseURLForApp URLByAppendingPathComponent:routePath].absoluteString;
	
	[[JLRoutes globalRoutes] addRoute:fullRoutePath handler:handlerBlock];
	
	return self;
}

@end
