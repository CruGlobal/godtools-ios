//
//  GTLanguage.h
//  godtools
//
//  Created by Michael Harrison on 10/13/15.
//  Copyright © 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GTPackage;

NS_ASSUME_NONNULL_BEGIN

@interface GTLanguage : NSManagedObject

+ (instancetype)languageWithCode:(NSString *)code inContext:(NSManagedObjectContext *)context;
- (NSComparisonResult)compare:(GTLanguage *)otherLanguage;
- (BOOL)hasUpdates;

@end

NS_ASSUME_NONNULL_END

#import "GTLanguage+CoreDataProperties.h"
