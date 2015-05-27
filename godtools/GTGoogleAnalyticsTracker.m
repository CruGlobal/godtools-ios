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
#import "GTConfig.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAITracker.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

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
        
        [GAI sharedInstance].trackUncaughtExceptions = YES;
		
#ifdef DEBUG
		[GAI sharedInstance].dryRun = YES;
		[[GAI sharedInstance].logger setLogLevel:kGAILogLevelError];
#endif
		
        self.tracker = [[GAI sharedInstance] trackerWithTrackingId:[GTConfig sharedConfig].apiKeyGoogleAnalytics];
    }
    
    return self;
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

@end