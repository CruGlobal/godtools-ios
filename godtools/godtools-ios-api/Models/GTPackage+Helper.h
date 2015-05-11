//
//  GTPackage+Helper.h
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTPackage.h"

@interface GTPackage (Helper)

+ (instancetype)packageWithCode:(NSString *)code language:(GTLanguage *)language inContext:(NSManagedObjectContext *)context;
+ (NSString *)identifierWithPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode;
- (BOOL)hasUpdate;

@end
