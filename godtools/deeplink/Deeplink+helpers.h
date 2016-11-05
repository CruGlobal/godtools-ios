//
//  Deeplink+helpers.h
//  godtools
//
//  Created by Michael Harrison on 11/5/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

@class Deeplink;

@interface Deeplink (helpers)

@property (nonatomic, strong)			NSMutableDictionary *params;
@property (nonatomic, strong)			NSString			*pathComponentPattern;
@property (nonatomic, strong)			NSMutableDictionary	*pathComponents;

- (instancetype)addParamWithName:(NSString *)name
						   value:(NSString *)value;

- (instancetype)addPathComponentWithName:(NSString *)name
								   value:(NSString *)value;

@end
