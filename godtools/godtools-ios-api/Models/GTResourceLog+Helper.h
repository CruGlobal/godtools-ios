//
//  GTResourceLog+Helper.h
//  godtools
//
//  Created by Michael Harrison on 3/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTResourceLog.h"
#import "GTLanguage.h"
#import "GTPackage.h"

@interface GTResourceLog (Helper)

@property (nonatomic, retain) GTLanguage *currentLanguage;
@property (nonatomic, retain) GTPackage *currentPackage;
@property (nonatomic, retain) GTLanguage *currentParallelLanguage;

@end
