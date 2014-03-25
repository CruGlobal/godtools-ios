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
#import "GTDefaults.h"

@interface GTDataImporter : NSObject

+ (instancetype)sharedImporter;
- (instancetype)initWithAPI:(GTAPI *)api storage:(GTStorage *)storage defaults:(GTDefaults *)defaults;

- (void)updateMenuInfo;

//////////Methods for Automatic model//////////
//methods for updating with default data binding working (ie you have injected a GTDefaults object into the initializer)
//downloading and checking for updates will happen automatically you just have to initiate the updates.
//////////////////////////////////////////////
- (void)updatePackagesWithNewVersions;

//////////Methods for Manual model/////////////
//methods for manual downloading and updating. You don't have to use these if you provided a GTDefaults object.
//////////////////////////////////////////////
- (void)downloadPackagesForLanguage:(GTLanguage *)language;
- (void)checkForPackagesWithNewVersionsForLanguage:(GTLanguage *)language;
- (void)updatePackagesWithNewVersionsForLanguage:(GTLanguage *)langauge;

@end
