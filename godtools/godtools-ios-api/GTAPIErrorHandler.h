//
//  GTAPIErrorHandler.h
//  godtools
//
//  Created by Michael Harrison on 3/20/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTAPIErrorHandler : NSObject

+ (instancetype)sharedErrorHandler;
- (void)displayError:(NSError *)error;

@end
