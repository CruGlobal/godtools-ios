//
//  GTDataImporter.h
//  godtools
//
//  Created by Michael Harrison on 3/18/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTAPI.h"
#import "GTStorage.h"

@interface GTDataImporter : NSObject

+ (instancetype)sharedImporter;
- (instancetype)initWithAPI:(GTAPI *)api storage:(GTStorage *)storage;

- (void)updateMenuInfo;
- (void)updatePackagesForLanguage;

@end
