//
//  GTStorageErrorHandler.m
//  godtools
//
//  Created by Michael Harrison on 3/24/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTStorageErrorHandler.h"

@implementation GTStorageErrorHandler

- (void)displayError:(NSError *)error {
	
<<<<<<< HEAD
=======
    NSLog(@"error============== %@",error.description);
    
>>>>>>> refs/heads/elementzMaster
#warning incomplete impelementation. Error specific handling should go here to catch general storage errors like cannot open.
	
#warning GTStorage assumes error handler will display an error that blocks everything and tells the users to relaunch the app in the case of a cannot open error.
	
<<<<<<< HEAD
=======
    
    
>>>>>>> refs/heads/elementzMaster
	[super displayError:error];
}

@end
