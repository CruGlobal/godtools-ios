//
//  GTLanguage+Helper.h
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTLanguage.h"

@interface GTLanguage (Helper)

+ (instancetype)languageWithCode:(NSString *)code inContext:(NSManagedObjectContext *)context;

@end
