//
//  GTSettingsViewController.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTSettingsViewController.h"
#import "GTLanguagesViewController.h"
#import "GTLanguage.h"
#import "GTStorage.h"
#import "GTDefaults.h"
#import "GTDataImporter.h"

#import "GTGoogleAnalyticsTracker.h"

#import "GTSettingsAboutGodToolsViewController.h"

@interface GTSettingsViewController ()

@property (strong, nonatomic) GTLanguage *mainLanguage;
@property (strong, nonatomic) GTLanguage *parallelLanguage;

@property (strong, nonatomic) UIAlertView *exitTranslatorModeAlert;
@property (strong, nonatomic) UIAlertView *buttonLessAlert;

@property (strong, nonatomic) IBOutlet UIButton *primaryLanguageButton;
@property (strong, nonatomic) IBOutlet UIButton *parallelLanguageButton;
@property (strong, nonatomic) IBOutlet UILabel *primaryLanguageLabel;
@property (strong, nonatomic) IBOutlet UILabel *parallelLanguageLabel;
@property (strong, nonatomic) IBOutlet UILabel *previewModeLabel;
@property (strong, nonatomic) IBOutlet UISwitch *previewModeSwitch;
@property (strong, nonatomic) IBOutlet UILabel *parallelModeTapInstructions;
@property (strong, nonatomic) IBOutlet UILabel *parallelModeSwitchButtonInstructions;
@property (strong, nonatomic) IBOutlet UILabel *parallelModeToggleExplaination;

- (IBAction)previewModeSwitchPressed;
- (IBAction)changePrimaryLanguagePressed;
- (IBAction)changeParallelLanguagePressed;

@property AFNetworkReachabilityManager *afReachability;

@end

@implementation GTSettingsViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.previewModeLabel.text = NSLocalizedString(@"settings_translator_mode", nil);
    self.primaryLanguageLabel.text = NSLocalizedString(@"settings_main_language", nil);
    self.parallelLanguageLabel.text = NSLocalizedString(@"settings_parallel_language", nil);
	
	self.parallelModeTapInstructions.text = NSLocalizedString(@"settings_parallel_info_tap", nil);
	self.parallelModeSwitchButtonInstructions.text = NSLocalizedString(@"settings_parallel_info_switch_button", nil);
	self.parallelModeToggleExplaination.text = NSLocalizedString(@"settings_parallel_info_toggle_explaination", nil);
    
    [self setLanguageNameLabelValues];
    
    self.exitTranslatorModeAlert = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"dialog_translator_mode_title", nil)
                                        message:NSLocalizedString(@"dialog_translator_mode_body", nil)
                                        delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"no", nil)
                                        otherButtonTitles:NSLocalizedString(@"yes", nil),nil];
    
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
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)] &&
        [self.navigationController.navigationBar respondsToSelector:@selector(setTranslucent:)]) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.44 green:0.84 blue:0.88 alpha:1.0]];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setTranslucent:NO]; // required for iOS7
    }
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"settings_title", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self.previewModeSwitch setOn: [[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.afReachability = [AFNetworkReachabilityManager managerForDomain:@"www.google.com"];
    [self.afReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status < AFNetworkReachabilityStatusReachableViaWWAN) {
            NSLog(@"No internet connection!");
        }
    }];
    
    [[[GTGoogleAnalyticsTracker sharedInstance] setScreenName:@"SettingsScreen"] sendScreenView];
    
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

#pragma mark - Outlets

- (IBAction)changeParallelLanguagePressed {
    [GTDefaults sharedDefaults].isChoosingForMainLanguage = NO;
    [self performSegueWithIdentifier:@"settingsToLanguageViewSegue" sender:self];
}

- (IBAction)previewModeSwitchPressed {
    if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:NO]){
        [self performSegueWithIdentifier:@"settingsToAccessCodeScreenSegue" sender:self];
    }else{
        [self.exitTranslatorModeAlert show];
    }
}

- (IBAction)changePrimaryLanguagePressed {
    [GTDefaults sharedDefaults].isChoosingForMainLanguage = YES;
    [self performSegueWithIdentifier:@"settingsToLanguageViewSegue" sender:self];
}

#pragma mark - UI Utilities

- (void)setLanguageNameLabelValues {
	
	NSString *localizedMainLanguageName = [[[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:self.mainLanguage.code] capitalizedString];
	localizedMainLanguageName = ( !localizedMainLanguageName || [localizedMainLanguageName isEqualToString:self.mainLanguage.code] ? self.mainLanguage.name.capitalizedString : localizedMainLanguageName.capitalizedString );
	[self.primaryLanguageButton setTitle:localizedMainLanguageName forState:UIControlStateNormal];

    if([self parallelLanguage] == nil) {
        [self.parallelLanguageButton setTitle: NSLocalizedString(@"settings_language_none_selected", nil) forState:UIControlStateNormal];
    } else {
		NSString *localizedParallelLanguageName = [[[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:self.parallelLanguage.code] capitalizedString];
		localizedParallelLanguageName = ( [localizedParallelLanguageName isEqualToString:self.parallelLanguage.code] ? self.parallelLanguage.name.capitalizedString : localizedParallelLanguageName.capitalizedString );
        [self.parallelLanguageButton setTitle:localizedParallelLanguageName forState:UIControlStateNormal];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView == self.exitTranslatorModeAlert){
        if(buttonIndex == 1){
                [[GTDefaults sharedDefaults]setIsInTranslatorMode:[NSNumber numberWithBool:NO]];
                [self.previewModeSwitch setOn:NO animated:YES];
        }else{
                [self.previewModeSwitch setOn:YES animated:YES];
        }
    }
}

@end
