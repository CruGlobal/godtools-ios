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

@interface GTSettingsViewController ()

@property (strong, nonatomic) GTLanguage *mainLanguage;
@property (strong, nonatomic) GTLanguage *parallelLanguage;
@property (strong, nonatomic) UISwitch *translatorSwitch;
@property (strong, nonatomic) UIAlertView *translatorModeAlert;
@property (strong, nonatomic) UIAlertView *exitTranslatorModeAlert;

@end

@implementation GTSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setBounces:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    //self.tableView.estimatedRowHeight = 44.0;
    
    self.translatorSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.translatorSwitch addTarget:self action:@selector(translatorSwitchToggled) forControlEvents:UIControlEventTouchUpInside];
    
    self.translatorModeAlert = [[UIAlertView alloc]initWithTitle:@"" message:@"Enter Access Code" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    self.translatorModeAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.translatorModeAlert textFieldAtIndex:0].delegate = self;
    
    self.exitTranslatorModeAlert = [[UIAlertView alloc]initWithTitle:@"Exit Preview Mode?" message:@"Drafts will not be displayed" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];

    [self.tableView reloadData];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GTSettingsViewCell *cell = (GTSettingsViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GTSettingsViewCell"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GTSettingsViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.label.text = @"Main language";
            break;
        case 1:
            cell.label.text = self.mainLanguage.name;
            [cell addSeparator];
            [cell setAsLanguageSelector];
            break;
        case 2:
            cell.label.text = @"Parallel language";
            break;
        case 3:
            if(self.parallelLanguage){
                cell.label.text = self.parallelLanguage.name;
            }else{
                cell.label.text = @"None";
            }
            [cell addSeparator];
            break;
        case 4:
            cell.label.text = @"You can select a primary and parallel language that you can switch to at any time";
            [cell addSeparator];
            break;
        case 5:
            cell.label.text = @"If you are a GodTools translator wanting to see your latest translations, enable Preview Mode";
            break;
        case 6:
            cell.label.text = @"Preview Mode";
            cell.accessoryView = self.translatorSwitch;
            if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){
                [self.translatorSwitch setOn:YES animated:NO];
            }
            break;
        default:
            break;
    }
    //[cell setNeedsUpdateConstraints];
    //[cell updateConstraintsIfNeeded];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 1:
            [self performSegueWithIdentifier:@"settingsToLanguageViewSegue" sender:self];
            break;
        case 2:
            //cell.label.text = @"Parallel language";
            break;
        case 3:
            [self performSegueWithIdentifier:@"settingsToLanguageViewSegue" sender:self];
            break;
        default:
            break;
    }
    
}

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
            #warning validate access code
            if(YES){
                [[GTDefaults sharedDefaults]setIsInTranslatorMode:[NSNumber numberWithBool:YES]];
                [self.translatorSwitch setOn:YES animated:YES];
            }
        }else{
            [self.translatorSwitch setOn:NO animated:YES];
        }
    }
}



@end
