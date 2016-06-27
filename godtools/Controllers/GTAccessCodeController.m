//
//  GTAccessCodeController.m
//  godtools
//
//  Created by Ryan Carlson on 3/5/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTAccessCodeController.h"
#import "GTDataImporter.h"
#import "GTHomeViewController.h"

@interface GTAccessCodeController()

@property (strong, nonatomic) IBOutlet UITextField *accessCodeTextField;
@property (strong, nonatomic) UIAlertView *accessCodeStatusAlert;

@end

@implementation GTAccessCodeController

# pragma mark - View lifecycle methods
-(void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"dialog_access_code_title", nil);
	self.accessCodeTextField.placeholder = NSLocalizedString(@"access_code_placeholder", nil);
    self.navigationItem.backBarButtonItem.target = self;
    self.navigationItem.backBarButtonItem.action = @selector(cancelButtonPressed);

    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(doneButtonPressed);
    
    self.accessCodeStatusAlert = [[UIAlertView alloc]
                                   initWithTitle:@""
                                   message:@""
                                   delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:nil, nil];
    
    self.accessCodeTextField.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.accessCodeTextField becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self removeNotificationObservers];
}

#pragma mark - Notification Observers
-(void)addNotificationObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authorizeTranslatorAlert:)
                                                 name: GTDataImporterNotificationAuthTokenUpdateStarted
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authorizeTranslatorAlert:)
                                                 name: GTDataImporterNotificationAuthTokenUpdateSuccessful
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authorizeTranslatorAlert:)
                                                 name: GTDataImporterNotificationAuthTokenUpdateFail
                                               object:nil];
}

-(void)removeNotificationObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GTDataImporterNotificationAuthTokenUpdateStarted
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GTDataImporterNotificationAuthTokenUpdateSuccessful
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GTDataImporterNotificationAuthTokenUpdateFail
                                                  object:nil];
}

# pragma mark - UI helper methods
-(void) cancelButtonPressed {
    [self performSegueWithIdentifier:@"returnFromAccessCodeView" sender:self];
}

-(void) doneButtonPressed {
    [self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    [self addNotificationObservers];
    
    NSString *accessCode = self.accessCodeTextField.text;
    
    [[GTDataImporter sharedImporter]authorizeTranslator :accessCode];
    
    return YES;
}

-(void)authorizeTranslatorAlert:(NSNotification *) notification{
    
    NSLog(@"notif %@", notification.name);
    
    if([notification.name isEqualToString:GTDataImporterNotificationAuthTokenUpdateStarted]){
        NSLog(@"AUTHENTICATING_____++++++");
        //if([AFNetworkReachabilityManager sharedManager].reachable){
        NSLog(@"reachable");
        self.accessCodeStatusAlert.message = NSLocalizedString(@"authenticate_code", nil);
        [self.accessCodeStatusAlert show];
        //}
    }else if([notification.name isEqualToString:GTDataImporterNotificationAuthTokenUpdateFail]){
        if(notification.userInfo != nil){
            NSError *error = (NSError*)[notification.userInfo objectForKey:@"Error"];
            self.accessCodeStatusAlert.message = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            [self.accessCodeStatusAlert show];
            
            [self performSelector:@selector(dismissAlertView:) withObject:self.accessCodeStatusAlert afterDelay:2.0];
        }
        
        self.accessCodeTextField.text = nil;
        
    }else if([notification.name isEqualToString:GTDataImporterNotificationAuthTokenUpdateSuccessful]){
        if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){
            self.accessCodeStatusAlert.message = NSLocalizedString(@"translator_enabled", nil);
            [self.accessCodeStatusAlert show];
            [self performSelector:@selector(dismissAlertView:) withObject:self.accessCodeStatusAlert afterDelay:2.0];
        }
    }
}

-(void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    if(alertView == self.accessCodeStatusAlert && [[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){
        
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        for (UIViewController *viewController in allViewControllers) {
            if ([viewController isKindOfClass:[GTHomeViewController class]]) {
                [self.navigationController popToViewController:viewController animated:NO];
            }
        }
    }
}

@end