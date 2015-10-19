//
//  GTUpdateTracker.h
//  godtools
//
//  Created by Michael Harrison on 5/15/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTPackage.h"
#import "GTLanguage.h"

@interface GTUpdateTracker : NSObject

@property (weak, nonatomic) id owner;

+ (instancetype)updateTrackerWithNotificationOwner:(id)owner;

- (void)updateInitiatedForLanguage:(GTLanguage *)language withMajorUpdates:(NSArray *)majorUpdates minorUpdates:(NSArray *)minorUpdates;
- (void)majorUpdateCompletedForLanguage:(GTLanguage *)language;
- (void)majorUpdateFailedForLanguage:(GTLanguage *)language;
- (void)minorUpdateCompletedForPackage:(GTPackage *)package;
- (void)minorUpdateFailedForPackage:(GTPackage *)package;
- (NSArray *)updateCancelledForLanguage:(GTLanguage *)language;
- (NSArray *)updateCancelled;

- (BOOL)hasFinishedUpdatingLanguage:(GTLanguage *)language;

@end
