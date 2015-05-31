//
//  GTLanguage.h
//  
//
//  Created by Michael Harrison on 5/11/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GTPackage;

@interface GTLanguage : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * downloaded;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * updatesAvailable;
@property (nonatomic, retain) NSSet *packages;
@end

@interface GTLanguage (CoreDataGeneratedAccessors)

- (void)addPackagesObject:(GTPackage *)value;
- (void)removePackagesObject:(GTPackage *)value;
- (void)addPackages:(NSSet *)values;
- (void)removePackages:(NSSet *)values;

@end
