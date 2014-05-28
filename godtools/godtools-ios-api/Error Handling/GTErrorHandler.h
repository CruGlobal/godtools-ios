//
//  GTErrorHandler.h
//  godtools
//
//  Created by Michael Harrison on 3/24/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Super Class for displaying errors.
 */
@interface GTErrorHandler : NSObject

/**
 *  Singleton method for Error Handlers. Can be used by subclasses.
 *
 *  @return initialized error handler
 */
+ (instancetype)sharedErrorHandler;

/**
 *  Logs errors to the console.
 *
 *  @note designed to be subclassed for production code.
 *
 *  @param error error to be displayed
 */
- (void)displayError:(NSError *)error;

@end
