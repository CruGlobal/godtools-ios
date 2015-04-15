//
//  GTGoogleAnalyticsTracker.h
//  MissionHub
//
//  Created by Michael Harrison on 10/29/13.
//  Copyright (c) 2013 Cru. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GTGoogleAnalyticsCategoryUI;
extern NSString * const GTGoogleAnalyticsCategoryBackgroundProcess;
extern NSString * const GTGoogleAnalyticsCategoryButton;
extern NSString * const GTGoogleAnalyticsCategoryCell;
extern NSString * const GTGoogleAnalyticsCategoryCheckbox;
extern NSString * const GTGoogleAnalyticsCategorySearchbar;
extern NSString * const GTGoogleAnalyticsCategoryList;
extern NSString * const GTGoogleAnalyticsCategoryPopover;
extern NSString * const GTGoogleAnalyticsCategoryActivityBar;

extern NSString * const GTGoogleAnalyticsActionTap;
extern NSString * const GTGoogleAnalyticsActionSwipe;

@interface GTGoogleAnalyticsTracker : NSObject

+ (void)start;
+ (GTGoogleAnalyticsTracker *)sharedInstance;

- (instancetype)setScreenName:(NSString *)screenName;

- (void)sendScreenView;
- (void)sendEventWithLabel:(NSString *)label;
- (void)sendEventWithCategory:(NSString *)category label:(NSString *)label;
- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

- (void)sendScreenViewWithScreenName:(NSString *)screenName;
- (void)sendEventWithScreenName:(NSString *)screenName label:(NSString *)label;
- (void)sendEventWithScreenName:(NSString *)screenName category:(NSString *)category label:(NSString *)label;
- (void)sendEventWithScreenName:(NSString *)screenName category:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

@end