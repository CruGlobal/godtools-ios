//
//  GTResourceLog.h
//  godtools
//
//  Created by Michael Harrison on 3/19/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTDefaults : NSObject

@property (nonatomic, strong) NSString *currentPackageCode;
@property (nonatomic, strong) NSString *currentLanguageCode;
@property (nonatomic, strong) NSString *currentParallelLanguageCode;

+ (instancetype)sharedDefaults;

@end
