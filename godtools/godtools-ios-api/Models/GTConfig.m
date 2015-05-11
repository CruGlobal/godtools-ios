//
//  MHConfig.m
//  MissionHub
//
//  Created by Michael Harrison on 10/28/13.
//  Copyright (c) 2013 Cru. All rights reserved.
//

#import "GTConfig.h"

@implementation GTConfig

+ (GTConfig *)sharedConfig {
	
	static GTConfig *_sharedConfig;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		
		_sharedConfig					= [[GTConfig alloc] init];
		
	});
	
	return _sharedConfig;
	
}

- (id)init {
	
    self = [super init];
    
	if (self) {
        
		//read config file
		NSString *configFilePath		= [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
		NSDictionary *configDictionary	= [NSDictionary dictionaryWithContentsOfFile:configFilePath];
		
		//set urls base on mode
		NSString *baseUrlString			= ( [configDictionary valueForKey:@"base_url"] ? [configDictionary valueForKey:@"base_url"] : @"" );
		_baseUrl						= [NSURL URLWithString:baseUrlString];
		
		//set interpreter version
		_interpreterVersion				= ( [configDictionary valueForKey:@"interpreter_version"] ? [configDictionary valueForKey:@"interpreter_version"] : @0 );
		
		//set api keys
		_apiKeyGodTools					= ( [configDictionary valueForKey:@"godtools_api_key"] ? [configDictionary valueForKey:@"godtools_api_key"] : @"" );
		_apiKeyErrbit					= ( [configDictionary valueForKey:@"errbit_api_key"] ? [configDictionary valueForKey:@"errbit_api_key"] : @"" );
		_apiKeyGoogleAnalytics			= ( [configDictionary valueForKey:@"google_analytics_api_key"] ? [configDictionary valueForKey:@"google_analytics_api_key"] : @"" );
		_apiKeyNewRelic					= ( [configDictionary valueForKey:@"newrelic_api_key"] ? [configDictionary valueForKey:@"newrelic_api_key"] : @"" );

		
    }
	
    return self;
}

@end
