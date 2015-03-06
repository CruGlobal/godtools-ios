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

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:<#animated#>];
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

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if(alertView == self.exitTranslatorModeAlert){
//        if(buttonIndex == 1){
//            [[GTDefaults sharedDefaults]setIsInTranslatorMode:[NSNumber numberWithBool:NO]];
//            [self.translatorSwitch setOn:NO animated:YES];
//        }else{
//            [self.translatorSwitch setOn:YES animated:YES];
//        }
//    }else if(alertView == self.translatorModeAlert){
//        if(buttonIndex == 1){
//            [self addNotificationObservers];
//            if([self.translatorModeAlert  textFieldAtIndex:0].text.length > 0){
//                NSString *accessCode = [self.translatorModeAlert  textFieldAtIndex:0].text;
//                [[GTDefaults sharedDefaults]setTranslatorAccessCode:accessCode];
//                [[GTDataImporter sharedImporter]authorizeTranslator];
//            }else{
//                self.buttonLessAlert.message = NSLocalizedString(@"AlertMesssage_invalidAccessCode", nil);
//                [self.buttonLessAlert show];
//                [self performSelector:@selector(dismissAlertView:) withObject:self.buttonLessAlert afterDelay:2.0];
//                [self.translatorSwitch setOn:NO animated:YES];
//            }
//        }else{
//            [self.translatorSwitch setOn:NO animated:YES];
//            [self.translatorModeAlert textFieldAtIndex:0].text = nil;
//        }
//    }
//}

# pragma mark - UI helper methods
-(void) cancelButtonPressed {
    [self performSegueWithIdentifier:@"returnFromAccessCodeView" sender:self];
}

-(void) doneButtonPressed {
    [self.accessCodeTextField resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self.accessCodeTextField resignFirstResponder];
    [self addNotificationObservers];
    
    NSString *accessCode = self.accessCodeTextField.text;
    
    [[GTDefaults sharedDefaults]setTranslatorAccessCode:accessCode];
    [[GTDataImporter sharedImporter]authorizeTranslator];
    
    return YES;
}

@end