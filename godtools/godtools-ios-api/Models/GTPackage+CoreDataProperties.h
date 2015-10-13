//
//  GTPackage+CoreDataProperties.h
//  godtools
//
//  Created by Michael Harrison on 10/13/15.
//  Copyright © 2015 Michael Harrison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GTPackage.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTPackage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *configFile;
@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) NSNumber *latestMajorVersion;
@property (nullable, nonatomic, retain) NSNumber *localMajorVersion;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *status;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *localSemanticVersion;
@property (nullable, nonatomic, retain) NSNumber *localMinorVersion;
@property (nullable, nonatomic, retain) NSNumber *latestMinorVersion;
@property (nullable, nonatomic, retain) NSString *latestSemanticVersion;
@property (nullable, nonatomic, retain) GTLanguage *language;

@end

NS_ASSUME_NONNULL_END
