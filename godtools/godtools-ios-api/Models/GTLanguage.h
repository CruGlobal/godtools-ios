//
//  GTLanguage.h
//  godtools
//
//  Created by Michael Harrison on 3/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GTPackage;

@interface GTLanguage : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * downloaded;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSSet *packages;
@end

@interface GTLanguage (CoreDataGeneratedAccessors)

- (void)addPackagesObject:(GTPackage *)value;
- (void)removePackagesObject:(GTPackage *)value;
- (void)addPackages:(NSSet *)values;
- (void)removePackages:(NSSet *)values;

@end
