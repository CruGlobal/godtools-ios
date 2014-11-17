//
//  GTHomeViewController.h
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GTViewController/GTViewController.h>
#import <GTViewController/GTFileLoader.h>
#import <GTViewController/GTPageMenuViewController.h>
#import <GTViewController/GTShareViewController.h>
#import <GTViewController/GTAboutViewController.h>
#import "GTHomeView.h"

@interface GTHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,GTViewControllerMenuDelegate, GTAboutViewControllerDelegate, GTHomeViewDelegate >

@property (strong, nonatomic) NSArray* articles;

@end
