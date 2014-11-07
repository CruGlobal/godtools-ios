//
//  GTSettingsManager.m
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTSettingsManager.h"

@implementation GTSettingsManager

@synthesize mainLanguage;

#pragma mark - Initialization and Setup

+ (id)sharedManager {
    
    static GTSettingsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedManager = [[GTSettingsManager alloc] init];
        
    });
    
    return sharedManager;
}


@end
