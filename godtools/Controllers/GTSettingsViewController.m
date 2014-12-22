//
//  GTSettingsViewController.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTSettingsViewController.h"
#import "GTLanguagesViewController.h"
#import "GTSettingsViewCell.h"
#import "GTLanguage+Helper.h"
#import "GTStorage.h"
#import "GTDefaults.h"
#import "GTDataImporter.h"

#import "GTSettingsAboutGodToolsViewController.h"

@interface GTSettingsViewController ()

@property (strong, nonatomic) GTLanguage *mainLanguage;
@property (strong, nonatomic) GTLanguage *parallelLanguage;
@property (strong, nonatomic) UISwitch *translatorSwitch;
@property (strong, nonatomic) UIAlertView *translatorModeAlert;
@property (strong, nonatomic) UIAlertView *exitTranslatorModeAlert;
@property (strong, nonatomic) UIAlertView *buttonLessAlert;
@property (strong, nonatomic) NSMutableArray *settingsOptions;

@end

@implementation GTSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setBounces:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView reloadData];
    
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
    
    self.translatorModeAlert    = [[UIAlertView alloc]
                                        initWithTitle:@""
                                        message:NSLocalizedString(@"AlertMessage_enterAccessCode", nil)
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Send", nil];
    
    self.translatorModeAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.translatorModeAlert textFieldAtIndex:0].delegate = self;
    [self.translatorModeAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
    
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
    
    if([AFNetworkReachabilityManager sharedManager].reachable){
        [[GTDataImporter sharedImporter]updateMenuInfo];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self removeNotificationObservers];
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingsOptions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    CGFloat maxHeight = MAXFLOAT;
    
    CGFloat constrainHeight = maxHeight;
    CGFloat constrainWidth  = tableView.frame.size.width;
    
    NSString *text       = [self.settingsOptions objectAtIndex:indexPath.row];
    
    CGSize constrainSize = CGSizeMake(constrainWidth, constrainHeight);
    CGSize labelSize = [text    sizeWithFont:[UIFont systemFontOfSize:15.0f]
                                constrainedToSize:constrainSize
                                lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat labelHeight = labelSize.height;
    
    return labelHeight + 25.0f;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GTSettingsViewCell *cell = (GTSettingsViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GTSettingsViewCell"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GTSettingsViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.label.text = [self.settingsOptions objectAtIndex:indexPath.row];

    switch (indexPath.row) {
        case 1:
            cell.label.text = self.mainLanguage.name;
            [cell addSeparatorWithCellHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
            [cell setAsLanguageSelector];
            break;
        case 3:
            if(self.parallelLanguage){
                cell.label.text = self.parallelLanguage.name;
            }
            [cell addSeparatorWithCellHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
            [cell setAsLanguageSelector];
            break;
        case 4:
            [cell addSeparatorWithCellHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
            break;
        case 6:
            cell.accessoryView = self.translatorSwitch;
            if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){
                [self.translatorSwitch setOn:YES animated:NO];
            }
            [cell addSeparatorWithCellHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
            break;
        default:
            break;
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GTSettingsAboutGodToolsViewController *aboutVC;
    
    switch (indexPath.row) {
        case 1:
            [self performSegueWithIdentifier:@"settingsToLanguageViewSegue" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"settingsToLanguageViewSegue" sender:self];
            break;
        case 7:
            
            if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending){
                aboutVC =[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"GTSettingsAboutGodToolsViewController"];
                aboutVC.providesPresentationContextTransitionStyle = YES;
                aboutVC.definesPresentationContext = YES;
                [aboutVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                 [self presentViewController:aboutVC animated:YES completion:nil];
            }else{
                [self.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
                [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                [self performSegueWithIdentifier:@"settingsToAboutViewSegue" sender:self];

            }
            break;
        default:
            break;
    }
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"settingsToLanguageViewSegue"]){

        if([self.tableView indexPathForSelectedRow].row == 1){
            
            [[GTDefaults sharedDefaults]setIsChoosingForMainLanguage:[NSNumber numberWithBool: YES]];
            
        }else if([self.tableView indexPathForSelectedRow].row == 3){
            
            [[GTDefaults sharedDefaults]setIsChoosingForMainLanguage:[NSNumber numberWithBool: NO]];
        
        }
        
    }
}

#pragma mark - UI Utilities

-(void)translatorSwitchToggled{
    if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:NO]){
        [self.translatorModeAlert show];
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
    }else if(alertView == self.translatorModeAlert){
        if(buttonIndex == 1){
            if([self.translatorModeAlert  textFieldAtIndex:0].text.length > 0){
                NSString *accessCode = [self.translatorModeAlert  textFieldAtIndex:0].text;
                [[GTDefaults sharedDefaults]setTranslatorAccessCode:accessCode];
                [[GTDataImporter sharedImporter]authorizeTranslator];
                [self addNotificationObservers];
            }else{
                self.buttonLessAlert.message = NSLocalizedString(@"AlertMesssage_invalidAccessCode", nil);
                [self.buttonLessAlert show];
                [self performSelector:@selector(dismissAlertView:) withObject:self.buttonLessAlert afterDelay:2.0];
                [self.translatorSwitch setOn:NO animated:YES];
            }
        }else{
            [self.translatorSwitch setOn:NO animated:YES];
            [self.translatorModeAlert textFieldAtIndex:0].text = nil;
        }
    }
}

-(void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    if(alertView == self.buttonLessAlert && [[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)authorizeTranslatorAlert:(NSNotification *) notification{
    
    NSLog(@"notif %@", notification.name);

    if([notification.name isEqualToString:GTDataImporterNotificationAuthTokenUpdateStarted]){
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        indicator.center = CGPointMake(self.buttonLessAlert.bounds.size.width / 2, self.buttonLessAlert.bounds.size.height - 50);
        [indicator startAnimating];
        [self.buttonLessAlert addSubview:indicator];
        
        self.buttonLessAlert.message = NSLocalizedString(@"AlertMessage_authenticatingAccessCode", nil);
        [self.buttonLessAlert show];
        
    }else if([notification.name isEqualToString:GTDataImporterNotificationAuthTokenUpdateFail]){
        
        self.buttonLessAlert.message = NSLocalizedString(@"AlertMesssage_invalidAccessCode", nil);
        [self.buttonLessAlert show];
        
        [self performSelector:@selector(dismissAlertView:) withObject:self.buttonLessAlert afterDelay:2.0];
        [self.translatorSwitch setOn:NO animated:YES];
        
        [self.translatorModeAlert textFieldAtIndex:0].text = nil;
        
    }else if([notification.name isEqualToString:GTDataImporterNotificationAuthTokenUpdateSuccessful]){
        
        if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){
            self.buttonLessAlert.message = NSLocalizedString(@"AlertMessage_previewModeEnabled", nil);
            [self.buttonLessAlert show];
            
            [self performSelector:@selector(dismissAlertView:) withObject:self.buttonLessAlert afterDelay:2.0];
            [self.translatorSwitch setOn:YES animated:YES];
            
            GTLanguage *current = [[[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults] currentLanguageCode] inBackground:YES]objectAtIndex:0];
            [[GTDataImporter sharedImporter]downloadPackagesForLanguage:current];
        }
    }
}


@end
