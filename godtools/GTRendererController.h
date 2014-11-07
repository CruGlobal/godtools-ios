//
//  GTRendererController.h
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTViewController.h"

@interface GTRendererController : GTViewController <GTViewControllerMenuDelegate, GTAboutViewControllerDelegate>

+ (instancetype)sharedInstance;

@end
