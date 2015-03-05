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

@property (strong, nonatomic) UISwitch *translatorSwitch;
@property (strong, nonatomic) UIAlertView *exitTranslatorModeAlert;
@property (strong, nonatomic) UIAlertView *buttonLessAlert;

@property (strong, nonatomic) NSMutableArray *settingsOptions;

@property AFNetworkReachabilityManager *afReachability;

@property BOOL shouldGoBackToHome;

@end

@implementation GTSettingsViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingsView = (GTSettingsView*) [[[NSBundle mainBundle] loadNibNamed:@"GTSettingsView" owner:nil options:nil] objectAtIndex:0];
    self.settingsView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view = self.settingsView;
    
    self.settingsView.delegate = self;
    
    UILabel *mainLanguagelabel =  [[UILabel alloc] initWithFrame: CGRectMake(30,197,280,21)];
    mainLanguagelabel.text = NSLocalizedString(@"GTSettings_mainLanguage_label", nil);
    mainLanguagelabel.textColor = [UIColor whiteColor];
    [self.view addSubview:mainLanguagelabel];

    UILabel *parallelLanguagelabel =  [[UILabel alloc] initWithFrame: CGRectMake(30,302,280,21)];
    parallelLanguagelabel.text = NSLocalizedString(@"GTSettings_parallelLanguage_label", nil);
    parallelLanguagelabel.textColor = [UIColor whiteColor];
    [self.view addSubview:parallelLanguagelabel];
    
    UILabel *previewModelabel =  [[UILabel alloc] initWithFrame: CGRectMake(30,106,280,21)];
    previewModelabel.text = NSLocalizedString(@"GTSettings_previewMode_label", nil);
    previewModelabel.textColor = [UIColor whiteColor];
    [self.view addSubview:previewModelabel];
    
    UILabel *previewModeInstructions =  [[UILabel alloc] initWithFrame: CGRectMake(30,400,280,106)];
    previewModeInstructions.text = NSLocalizedString(@"GTSettings_parallelModeInstructions", nil);
    previewModeInstructions.textColor = [UIColor whiteColor];
    previewModeInstructions.numberOfLines = 0;
    [self.view addSubview:previewModeInstructions];
    
    [self addLanguageNameLabel];
    [self addParallelLanguageNameLabel];

    self.settingsOptions = [[NSMutableArray alloc]initWithArray:@[
                                  NSLocalizedString(@"GTSettings_mainLanguage_label", nil),
                                  @"English",
                                  NSLocalizedString(@"GTSettings_parallelLanguage_label", nil),
                                  NSLocalizedString(@"GTSettings_parallelLanguage_default", nil),
                                  NSLocalizedString(@"GTSettings_languageInstructions", nil),
                                  NSLocalizedString(@"GTSettings_previewModeInstructions", nil),
                                  NSLocalizedString(@"GTSettings_previewMode_label", nil),
                                  NSLocalizedString(@"GTSettings_aboutGodTools", nil),
                              ]];
    
    
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
    
    
    self.translatorSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.translatorSwitch addTarget:self action:@selector(translatorSwitchToggled) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.shouldGoBackToHome = NO;
    
    [self setLanguageNameLabelValues];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.44 green:0.84 blue:0.88 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:NO]; // required for iOS7
    self.navigationController.navigationBar.topItem.title = @"Settings";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
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

-(void)chooseParallelLanguageButtonPressed{
    [[GTDefaults sharedDefaults]setIsChoosingForMainLanguage:[NSNumber numberWithBool: NO]];
    [self performSegueWithIdentifier:@"settingsToLanguageViewSegue" sender:self];
}

-(void)previewModeSwitchPressed{
    [self performSegueWithIdentifier:@"settingsToAccessCodeScreenSegue" sender:self];
}

#pragma mark - UI Utilities

-(void)translatorSwitchToggled{
    if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:NO]){
        //if([AFNetworkReachabilityManager sharedManager].reachable){
        if(self.afReachability.reachable){

        }else{
            self.buttonLessAlert.message = NSLocalizedString(@"You need to be online to proceed", nil);
            [self.buttonLessAlert show];
            [self performSelector:@selector(dismissAlertView:) withObject:self.buttonLessAlert afterDelay:2.0];
            [self.translatorSwitch setOn:NO animated:YES];
        }
    }else{
        [self.exitTranslatorModeAlert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView == self.exitTranslatorModeAlert){
        if(buttonIndex == 1){
            [[GTDefaults sharedDefaults]setIsInTranslatorMode:[NSNumber numberWithBool:NO]];
            [self.translatorSwitch setOn:NO animated:YES];
        }else{
            [self.translatorSwitch setOn:YES animated:YES];
        }
    }
}

-(void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    if(alertView == self.buttonLessAlert && [[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){
    //if(alertView == self.buttonLessAlert && self.shouldGoBackToHome){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)authorizeTranslatorAlert:(NSNotification *) notification{
    
    NSLog(@"notif %@", notification.name);

    if([notification.name isEqualToString:GTDataImporterNotificationAuthTokenUpdateStarted]){
        NSLog(@"AUTHENTICATING_____++++++");
        //if([AFNetworkReachabilityManager sharedManager].reachable){
            NSLog(@"reachable");
            self.buttonLessAlert.message = NSLocalizedString(@"AlertMessage_authenticatingAccessCode", nil);
            [self.buttonLessAlert show];
        //}
    }else if([notification.name isEqualToString:GTDataImporterNotificationAuthTokenUpdateFail]){
        if(notification.userInfo != nil){
            NSError *error = (NSError*)[notification.userInfo objectForKey:@"Error"];
            self.buttonLessAlert.message = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            [self.buttonLessAlert show];
            
            [self performSelector:@selector(dismissAlertView:) withObject:self.buttonLessAlert afterDelay:2.0];
        }
        [self.translatorSwitch setOn:NO animated:YES];
                
    }else if([notification.name isEqualToString:GTDataImporterNotificationAuthTokenUpdateSuccessful]){
        
        if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){
            self.buttonLessAlert.message = NSLocalizedString(@"AlertMessage_previewModeEnabled", nil);
            [self.buttonLessAlert show];
            self.shouldGoBackToHome = YES;
            [self performSelector:@selector(dismissAlertView:) withObject:self.buttonLessAlert afterDelay:2.0];
            [self.translatorSwitch setOn:YES animated:YES];
            
            GTLanguage *current = [[[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults] currentLanguageCode] inBackground:YES]objectAtIndex:0];
            [[GTDefaults sharedDefaults]setIsChoosingForMainLanguage:[NSNumber numberWithBool:YES]];
            [[GTDataImporter sharedImporter]downloadPackagesForLanguage:current];
        }
    }
}

- (void)addLanguageNameLabel {
    self.settingsView.languageNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(30,242,200,21)];
    self.settingsView.languageNameLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.settingsView.languageNameLabel];
}

- (void)addParallelLanguageNameLabel {
    self.settingsView.parallelLanguageNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(30,347,200,21)];
    self.settingsView.parallelLanguageNameLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.settingsView.parallelLanguageNameLabel];
}

- (void)setLanguageNameLabelValues {
    self.settingsView.languageNameLabel.text = [[self mainLanguage].name uppercaseString];
    
    if([self parallelLanguage] == nil) {
        self.settingsView.parallelLanguageNameLabel.text = @"None Selected";
    }
    else {
        self.settingsView.parallelLanguageNameLabel.text = [[self parallelLanguage].name uppercaseString];
    }
}

@end
