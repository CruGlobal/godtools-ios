//
//  MHConfig.h
//  MissionHub
//
//  Created by Michael Harrison on 10/28/13.
//  Copyright (c) 2013 Cru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTConfig : NSObject

@property (nonatomic, strong, readonly) NSURL		*baseUrl;
@property (nonatomic, strong, readonly) NSURL		*baseShareUrl;
@property (nonatomic, strong, readonly) NSNumber	*interpreterVersion;

@property (nonatomic, strong, readonly) NSString	*apiKeyGodTools;
@property (nonatomic, strong, readonly) NSString	*apiKeyRollbar;
@property (nonatomic, strong, readonly) NSString	*apiKeyGoogleAnalytics;
@property (nonatomic, strong, readonly) NSString	*apiKeyNewRelic;

@property (nonatomic, strong, readonly) NSURL       *followUpApiUrl;
@property (nonatomic, strong, readonly) NSString    *followUpApiSharedKey;
@property (nonatomic, strong, readonly) NSString    *followUpApiSecretKey;
@property (nonatomic, strong, readonly) NSString    *followUpApiDefaultRouteId;

+ (GTConfig *)sharedConfig;

@end
