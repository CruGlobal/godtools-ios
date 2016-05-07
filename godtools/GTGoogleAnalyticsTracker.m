//
//  GTGoogleAnalyticsTracker.m
//  godtools
//
//  Created by Ryan Carlson on 4/15/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//  GTGoogleAnalyticsTracker.m
//  MissionHub
//
//  Created by Michael Harrison on 10/29/13.
//  Copyright (c) 2013 Cru. All rights reserved.
//

#import "GTGoogleAnalyticsTracker.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAITracker.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <GTViewController/GTViewController.h>
#import "GTConfig.h"
#import "UISnuffleButton.h"

NSString * const GTGoogleAnalyticsCategoryUI				= @"ui";
NSString * const GTGoogleAnalyticsCategoryBackgroundProcess	= @"background_process";
NSString * const GTGoogleAnalyticsCategoryButton			= @"button";
NSString * const GTGoogleAnalyticsCategoryCell				= @"cell";
NSString * const GTGoogleAnalyticsCategoryCheckbox			= @"checkbox";
NSString * const GTGoogleAnalyticsCategorySearchbar			= @"searchbar";
NSString * const GTGoogleAnalyticsCategoryList				= @"list";
NSString * const GTGoogleAnalyticsCategoryPopover			= @"popover";
NSString * const GTGoogleAnalyticsCategoryActivityBar		= @"activity_bar";

NSString * const GTGoogleAnalyticsActionTap		= @"tap";
NSString * const GTGoogleAnalyticsActionSwipe	= @"swipe";

@interface GTGoogleAnalyticsTracker ()

@property (nonatomic, strong) id<GAITracker> tracker;

- (void)didReceivePageViewNotification:(NSNotification *)notification;

@end

@implementation GTGoogleAnalyticsTracker

@synthesize tracker = _tracker;

+ (void)start {
    
    [self sharedInstance];
    
}

+ (GTGoogleAnalyticsTracker *)sharedInstance {
    
    static GTGoogleAnalyticsTracker *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance					= [[GTGoogleAnalyticsTracker alloc] init];
        
    });
    
    return sharedInstance;
    
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [GAI sharedInstance].trackUncaughtExceptions = NO;
		// Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
		[GAI sharedInstance].dispatchInterval = 20;
		
		// Optional: set Logger to VERBOSE for debug information.
		[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
		
#ifdef DEBUG
		[GAI sharedInstance].dryRun = YES;
		[[GAI sharedInstance].logger setLogLevel:kGAILogLevelError];
#endif
		
        self.tracker = [[GAI sharedInstance] trackerWithTrackingId:[GTConfig sharedConfig].apiKeyGoogleAnalytics];
        
        [self registerListeners];
    }
    
    return self;
}


- (void) registerListeners {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePageViewNotification:)
                                                 name:GTViewControllerNotificationPageView
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecieveButtonTapNotification:)
                                                 name:UISnuffleButtonNotificationButtonTapEvent
                                               object:nil];
}


- (instancetype)setScreenName:(NSString *)screenName {
    
    NSString *name = ( screenName ? screenName : @"" );
    
    [self.tracker set:kGAIScreenName value:name];
    
    return self;
    
}

- (void)sendScreenView {
    
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (void)sendEventWithLabel:(NSString *)label {
    
    [self sendEventWithCategory:nil action:nil label:label value:nil];
    
}

- (void)sendEventWithCategory:(NSString *)category label:(NSString *)label {
    
    [self sendEventWithCategory:category action:nil label:label value:nil];
    
}

- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
    
    NSString *categoryName	= ( category	? category		: GTGoogleAnalyticsCategoryButton );
    NSString *actionName	= ( action		? action		: GTGoogleAnalyticsActionTap );
    NSString *labelName		= ( label		? label			: @"" );
    NSNumber *number		= ( value		? value			: nil );
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryName		// Event category (required)
                                                               action:actionName		// Event action (required)
                                                                label:labelName			// Event label
                                                                value:number] build]];
    
}

- (void)sendScreenViewWithScreenName:(NSString *)screenName {
    
    NSString *screen		= ( screenName	? screenName	: @"" );
    
    [self.tracker send:[[[GAIDictionaryBuilder createAppView] set:screen forKey:kGAIScreenName] build]];
    
}

- (void)sendEventWithScreenName:(NSString *)screenName label:(NSString *)label {
    
    [self sendEventWithScreenName:nil category:nil action:nil label:label value:nil];
    
}

- (void)sendEventWithScreenName:(NSString *)screenName category:(NSString *)category label:(NSString *)label {
    
    [self sendEventWithScreenName:screenName category:category action:nil label:label value:nil];
    
}

- (void)sendEventWithScreenName:(NSString *)screenName category:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
    
    NSString *screen		= ( screenName	? screenName	: @"" );
    NSString *categoryName	= ( category	? category		: GTGoogleAnalyticsCategoryButton );
    NSString *actionName	= ( action		? action		: GTGoogleAnalyticsActionTap );
    NSString *labelName		= ( label		? label			: @"" );
    NSNumber *number		= ( value		? value			: nil );
    
    [self.tracker send:[[[GAIDictionaryBuilder createEventWithCategory:categoryName		// Event category (required)
                                                                action:actionName		// Event action (required)
                                                                 label:labelName			// Event label
                                                                 value:number]			// Event value
                         set:screen forKey:kGAIScreenName]		// Screen Name Event was triggered on
                        build]];
    
}

- (void)didReceivePageViewNotification:(NSNotification *)notification {
	
	NSString *packageCode = notification.userInfo[GTViewControllerNotificationPageViewUserInfoKeyPackage];
	NSString *languageCode = notification.userInfo[GTViewControllerNotificationPageViewUserInfoKeyLanguage];
	NSNumber *pageNumber = notification.userInfo[GTViewControllerNotificationPageViewUserInfoKeyPageNumber];
	
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	[tracker set:[GAIFields customDimensionForIndex:1]
		   value:packageCode];
	
	[tracker set:[GAIFields customDimensionForIndex:2]
		   value:languageCode];
	
	[tracker set:kGAIScreenName
		   value:[packageCode stringByAppendingString:[@"-" stringByAppendingString:pageNumber.stringValue]]];
	
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
	
}


- (void)didRecieveButtonTapNotification:(NSNotification *)notification {
    NSString *eventName = notification.userInfo[UISnuffleButtonNotificationButtonTapEventKeyEventName];
    NSString *packageCode = notification.userInfo[UISnuffleButtonNotificationButtonTapEventKeyPackageCode];
    
    // why these have to be in reverse order to get the correct output is beyond me.
    NSString *label = [NSString stringWithFormat:@"%@:%@", packageCode, eventName];
    
    [self sendEventWithLabel:label];
}


- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

@end