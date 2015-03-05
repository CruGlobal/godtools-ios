//
//  GTAccessCodeController.m
//  godtools
//
//  Created by Ryan Carlson on 3/5/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTAccessCodeController.h"

@interface GTAccessCodeController()

@property (strong, nonatomic) UITextField* accessCodeTextField;

@end

@implementation GTAccessCodeController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1];
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController.navigationBar setTranslucent:NO]; // required for iOS7
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
    //
    //f6f6f6
}

@end