//
//  GTSettingsManager.h
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLanguage+Helper.h"

@interface GTSettingsManager : NSObject


+ (instancetype)sharedManager;

@property (strong,nonatomic) GTLanguage *mainLanguage;

@end
