//
//  GTLanguage+CoreDataProperties.h
//  godtools
//
//  Created by Michael Harrison on 10/13/15.
//  Copyright © 2015 Michael Harrison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GTLanguage.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTLanguage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSNumber *downloaded;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *status;
@property (nullable, nonatomic, retain) NSNumber *updatesAvailable;
@property (nullable, nonatomic, retain) NSSet<GTPackage *> *packages;

@end

@interface GTLanguage (CoreDataGeneratedAccessors)

- (void)addPackagesObject:(GTPackage *)value;
- (void)removePackagesObject:(GTPackage *)value;
- (void)addPackages:(NSSet<GTPackage *> *)values;
- (void)removePackages:(NSSet<GTPackage *> *)values;

@end

NS_ASSUME_NONNULL_END
