//
//  GTHomeViewController.h
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTViewController+Helper.h"
#import <GTViewController/GTFileLoader.h>
#import <GTViewController/GTPageMenuViewController.h>
#import <GTViewController/GTShareViewController.h>
#import <GTViewController/GTAboutViewController.h>
#import "GTHomeView.h"

@interface GTHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, GTViewControllerMenuDelegate, GTAboutViewControllerDelegate, GTHomeViewDelegate >

@property (strong, nonatomic) NSMutableArray* articles;

@end
