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
#import "GTHomeViewCell.h"

@interface GTHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, GTViewControllerMenuDelegate, GTAboutViewControllerDelegate, GTHomeViewCellDelegate >

@property (strong, nonatomic) NSMutableArray* articles;
@property (strong, nonatomic) NSMutableArray* packagesWithNoDrafts;

@end
