//
//  GTPackage.h
//  godtools
//
//  Created by Michael Harrison on 3/27/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GTLanguage;

@interface GTPackage : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * configFile;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * localVersion;
@property (nonatomic, retain) NSNumber * latestVersion;
@property (nonatomic, retain) GTLanguage *language;

@end
