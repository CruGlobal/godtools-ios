//
//  MHConfig.m
//  MissionHub
//
//  Created by Michael Harrison on 10/28/13.
//  Copyright (c) 2013 Cru. All rights reserved.
//

#import "GTConfig.h"

@implementation GTConfig

+ (GTConfig *)sharedInstance {
	
	static GTConfig *sharedInstance;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		
		sharedInstance					= [[GTConfig alloc] init];
		
	});
	
	return sharedInstance;
	
}

- (id)init {
	
    self = [super init];
    
	if (self) {
        
		//read config file
		NSString *configFilePath		= [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
		NSDictionary *configDictionary	= [NSDictionary dictionaryWithContentsOfFile:configFilePath];
		
		//set urls base on mode
		NSString *baseUrlString			= ( [configDictionary valueForKey:@"base_url"] ? [configDictionary valueForKey:@"development_url"] : @"" );
		
		_baseUrl					= [NSURL URLWithString:baseUrlString];
		
		//set api keys
		_apiKeyErrbit				= ( [configDictionary valueForKey:@"errbit_api_key"] ? [configDictionary valueForKey:@"errbit_api_key"] : @"" );
		_apiKeyGoogleAnalytics		= ( [configDictionary valueForKey:@"google_analytics_api_key"] ? [configDictionary valueForKey:@"google_analytics_api_key"] : @"" );
		_apiKeyNewRelic				= ( [configDictionary valueForKey:@"newrelic_api_key"] ? [configDictionary valueForKey:@"newrelic_api_key"] : @"" );
		
    }
	
    return self;
}

@end
