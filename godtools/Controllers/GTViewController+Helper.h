//
//  GTViewController+Helper.h
//  godtools
//
//  Created by Claudine Bael on 12/3/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTViewController.h"
#import "GTPackage+Helper.h"

@interface GTViewController (Helper)

@property (strong, nonatomic) GTPackage *currentPackage;
@property (retain) UIAlertView *refreshDraftAlert;
-(void)addNotificationObservers;

@end
