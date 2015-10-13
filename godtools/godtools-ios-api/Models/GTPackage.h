//
//  GTPackage.h
//  godtools
//
//  Created by Michael Harrison on 10/13/15.
//  Copyright © 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GTLanguage;

NS_ASSUME_NONNULL_BEGIN

@interface GTPackage : NSManagedObject

+ (instancetype)packageWithCode:(NSString *)code language:(GTLanguage *)language inContext:(NSManagedObjectContext *)context;
+ (NSString *)identifierWithPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode;
- (BOOL)needsUpdate;
- (BOOL)needsMajorUpdate;
- (BOOL)needsMinorUpdate;
- (void)setIfGreaterThanLatestVersion:(NSString *)latestVersion;
- (NSString *)localVersion;
- (void)setLocalVersion:(NSString *)localVersion;
- (NSString *)latestVersion;
- (void)setLatestVersion:(NSString *)latestVersion;

@end

NS_ASSUME_NONNULL_END

#import "GTPackage+CoreDataProperties.h"
