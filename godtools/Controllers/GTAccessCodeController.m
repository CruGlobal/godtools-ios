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

@property (strong, nonatomic) IBOutlet UITextField *accessCodeTextField;
@end

@implementation GTAccessCodeController

# pragma mark - View lifecycle methods
-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem.target = self;
    self.navigationItem.backBarButtonItem.action = @selector(cancelButtonPressed);

    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(doneButtonPressed);
    
    self.accessCodeTextField.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1];
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    [self.navigationController.navigationBar setTranslucent:NO]; // required for iOS7
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.accessCodeTextField becomeFirstResponder];
}

# pragma mark - UI helper methods
-(void) cancelButtonPressed {
    [self performSegueWithIdentifier:@"returnFromAccessCodeView" sender:self];
}

-(void) doneButtonPressed {
    [self.accessCodeTextField resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self.accessCodeTextField resignFirstResponder];
    return YES;
}

@end