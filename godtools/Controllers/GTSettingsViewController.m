//
//  GTSettingsViewController.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTSettingsView.h"
#import "GTSettingsViewController.h"
#import "GTLanguagesViewController.h"
#import "GTSettingsViewCell.h"
#import "GTLanguage+Helper.h"
#import "GTStorage.h"
#import "GTDefaults.h"
#import "GTDataImporter.h"

#import "GTSettingsAboutGodToolsViewController.h"

@interface GTSettingsViewController ()

@property (strong, nonatomic) GTSettingsView *settingsView;

@property (strong, nonatomic) GTLanguage *mainLanguage;
@property (strong, nonatomic) GTLanguage *parallelLanguage;

@property (strong, nonatomic) UIAlertView *exitTranslatorModeAlert;
@property (strong, nonatomic) UIAlertView *buttonLessAlert;

@property AFNetworkReachabilityManager *afReachability;

@end

@implementation GTSettingsViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingsView = (GTSettingsView*) [[[NSBundle mainBundle] loadNibNamed:@"GTSettingsView" owner:nil options:nil] objectAtIndex:0];
    self.settingsView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    self.view = self.settingsView;
    
    self.settingsView.delegate = self;

    self.settingsView.previewModeLabel.text = NSLocalizedString(@"GTSettings_previewMode_label", nil);
    self.settingsView.languageLabel.text = NSLocalizedString(@"GTSettings_mainLanguage_label", nil);
    self.settingsView.parallelLanguageLabel.text = NSLocalizedString(@"GTSettings_parallelLanguage_label", nil);
    [self setLanguageNameLabelValues];
    
    self.exitTranslatorModeAlert = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"AlertTitle_exitPreviewMode", nil)
                                        message:NSLocalizedString(@"AlertMessage_exitPreviewMode", nil)
                                        delegate:self
                                        cancelButtonTitle:@"No"
                                        otherButtonTitles:@"Yes",nil];
    
    self.buttonLessAlert        = [[UIAlertView alloc]
                                        initWithTitle:@""
                                        message:@""
                                        delegate:self
                                        cancelButtonTitle:nil
                                        otherButtonTitles:nil, nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setLanguageNameLabelValues];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.44 green:0.84 blue:0.88 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:NO]; // required for iOS7
    self.navigationController.navigationBar.topItem.title = @"Settings";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self.settingsView.previewModeSwitch setOn: [[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.afReachability = [AFNetworkReachabilityManager managerForDomain:@"www.google.com"];
    [self.afReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status < AFNetworkReachabilityStatusReachableViaWWAN) {
            NSLog(@"No internet connection!");
        }
    }];
    
    [self.afReachability startMonitoring];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self removeNotificationObservers];
    [self.afReachability stopMonitoring];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Return segue methods
- (IBAction)returnFromAccessCodeView:(UIStoryboardSegue *)segue {

}

#pragma mark - Property getters
-(GTLanguage *)mainLanguage{
    
    NSString *mainLanguageCode = [[GTDefaults sharedDefaults] currentLanguageCode];
    NSArray *languages = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[mainLanguageCode] inBackground:NO];
    
    return (GTLanguage*)[languages objectAtIndex:0];
}

-(GTLanguage *)parallelLanguage{
    
    NSString *code = [[GTDefaults sharedDefaults] currentParallelLanguageCode];

    if(code != nil){
        NSArray *languages = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[code] inBackground:NO];
        return (GTLanguage*)[languages objectAtIndex:0];
    }else{
        return nil;
    }
}

#pragma mark - Settings view delegates

-(void)chooseLanguageButtonPressed {
    [[GTDefaults sharedDefaults]setIsChoosingForMainLanguage:[NSNumber numberWithBool: YES]];
    [self performSegueWithIdentifier:@"settingsToLanguageViewSegue" sender:self];
}

-(void)chooseParallelLanguageButtonPressed {
    [[GTDefaults sharedDefaults]setIsChoosingForMainLanguage:[NSNumber numberWithBool: NO]];
    [self performSegueWithIdentifier:@"settingsToLanguageViewSegue" sender:self];
}

-(void)previewModeSwitchPressed {
    if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:NO]){
        [self performSegueWithIdentifier:@"settingsToAccessCodeScreenSegue" sender:self];
    }else{
        [self.exitTranslatorModeAlert show];
    }
}

#pragma mark - UI Utilities

- (void)setLanguageNameLabelValues {
    self.settingsView.languageNameLabel.text = [[self mainLanguage].name uppercaseString];
    
    if([self parallelLanguage] == nil) {
        self.settingsView.parallelLanguageNameLabel.text = @"None Selected";
    }
    else {
        self.settingsView.parallelLanguageNameLabel.text = [[self parallelLanguage].name uppercaseString];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView == self.exitTranslatorModeAlert){
        if(buttonIndex == 1){
                [[GTDefaults sharedDefaults]setIsInTranslatorMode:[NSNumber numberWithBool:NO]];
                [self.settingsView.previewModeSwitch setOn:NO animated:YES];
        }else{
                [self.settingsView.previewModeSwitch setOn:YES animated:YES];
        }
    }
}

@end
