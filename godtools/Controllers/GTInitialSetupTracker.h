//
//  GTInitialSetupTracker.h
//  godtools
//
//  Created by Michael Harrison on 8/21/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const GTInitialSetupTrackerNotificationDidFinish;
extern NSString *const GTInitialSetupTrackerNotificationDidFail;

@interface GTInitialSetupTracker : NSObject

@property (nonatomic, assign) BOOL firstLaunch;

- (void)beganInitialSetup;
- (void)finishedExtractingMetaData;
- (void)failedExtractingMetaData;
- (void)finishedExtractingEnglishPackage;
- (void)failedExtractingEnglishPackage;
- (void)finishedDownloadingPhonesLanguage;
- (void)failedDownloadingPhonesLanguage;

@end
