//
//  Deeplink+helpers.m
//  godtools
//
//  Created by Michael Harrison on 11/5/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import "Deeplink.h"
#import "Deeplink+helpers.h"

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

@end
