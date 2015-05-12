//
//  GTPackage.h
//  
//
//  Created by Michael Harrison on 5/12/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GTLanguage;

@interface GTPackage : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * configFile;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * latestVersion;
@property (nonatomic, retain) NSString * localVersion;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) GTLanguage *language;

@end
