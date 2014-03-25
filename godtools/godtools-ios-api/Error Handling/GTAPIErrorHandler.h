//
//  GTAPIErrorHandler.h
//  godtools
//
//  Created by Michael Harrison on 3/20/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTErrorHandler.h"

@interface GTAPIErrorHandler : GTErrorHandler

+ (instancetype)sharedErrorHandler;

@end
