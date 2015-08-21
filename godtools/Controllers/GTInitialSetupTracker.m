//
//  GTInitialSetupTracker.m
//  godtools
//
//  Created by Michael Harrison on 8/21/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import "GTInitialSetupTracker.h"

NSString *const GTInitialSetupTrackerNotificationDidFinish = @"org.cru.godtools.gtinitialsetuptracker.notification.name.didfinish";
NSString *const GTInitialSetupTrackerNotificationDidFail = @"org.cru.godtools.gtinitialsetuptracker.notification.name.didfail";

NSString *const GTInitialSetupTrackerFirstLaunch = @"is_first_launch";

@interface GTInitialSetupTracker ()

@property (nonatomic, strong) NSMutableArray *successfulSteps;
@property (nonatomic, strong) NSMutableArray *failedSteps;

- (void)checkFinishedCondition;

@end

@implementation GTInitialSetupTracker

- (instancetype)init {
	
	self = [super init];
	if (self) {
		
		self.successfulSteps	= [NSMutableArray array];
		self.failedSteps		= [NSMutableArray array];
		
	}
	
	return self;
}

- (BOOL)firstLaunch{
	
	if (!_firstLaunch) {
		
		[self willChangeValueForKey:@"firstLaunch"];
		_firstLaunch = ( [[NSUserDefaults standardUserDefaults] objectForKey:GTInitialSetupTrackerFirstLaunch] ? YES : NO );
		[self didChangeValueForKey:@"firstLaunch"];
	}
	
	return _firstLaunch;
}

- (void)beganInitialSetup {
	
	[self.successfulSteps removeAllObjects];
	[self.failedSteps removeAllObjects];
	
}

- (void)finishedExtractingMetaData {
	
	[self.successfulSteps addObject:@"meta-data"];
	[self checkFinishedCondition];
	
}

- (void)failedExtractingMetaData {
	
	[self.failedSteps addObject:@"meta-data"];
	[self checkFinishedCondition];
	
}

- (void)finishedExtractingEnglishPackage {
	
	[self.successfulSteps addObject:@"english-package"];
	[self checkFinishedCondition];
	
}

- (void)failedExtractingEnglishPackage {
	
	[self.failedSteps addObject:@"english-package"];
	[self checkFinishedCondition];
	
}

- (void)finishedDownloadingPhonesLanguage {
	
	[self.successfulSteps addObject:@"phones-language"];
	[self checkFinishedCondition];
	
}

- (void)failedDownloadingPhonesLanguage {
	
	[self.failedSteps addObject:@"phones-language"];
	[self checkFinishedCondition];
	
}

- (void)checkFinishedCondition {
	
	if (self.failedSteps.count == 3) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GTInitialSetupTrackerNotificationDidFail object:self];
		
	} else {
	
		if (self.successfulSteps.count + self.failedSteps.count == 3) {
			
			[[NSNotificationCenter defaultCenter] postNotificationName:GTInitialSetupTrackerNotificationDidFinish object:self];
			
		}
		
	}
	
}


@end
