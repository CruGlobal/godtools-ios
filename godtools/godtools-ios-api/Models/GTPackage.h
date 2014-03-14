//
//  GTPackage.h
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GTLanguage, GTResourceLog;

@interface GTPackage : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * configFile;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSSet *languages;
@property (nonatomic, retain) GTResourceLog *resourceLog;
@end

@interface GTPackage (CoreDataGeneratedAccessors)

- (void)addLanguagesObject:(GTLanguage *)value;
- (void)removeLanguagesObject:(GTLanguage *)value;
- (void)addLanguages:(NSSet *)values;
- (void)removeLanguages:(NSSet *)values;

@end
