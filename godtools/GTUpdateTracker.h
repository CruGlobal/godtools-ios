//
//  GTUpdateTracker.h
//  godtools
//
//  Created by Michael Harrison on 5/15/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTPackage+Helper.h"

@interface GTUpdateTracker : NSObject

@property (weak, nonatomic) id owner;

+ (instancetype)updateTrackerWithNotificationOwner:(id)owner;

- (void)updateInitiatedForLanguage:(GTLanguage *)language withPackages:(NSArray *)packages;
- (void)updateCompletedForPackage:(GTPackage *)package;
- (void)updateFailedForPackage:(GTPackage *)package;
- (NSArray *)updateCancelled;

@end
