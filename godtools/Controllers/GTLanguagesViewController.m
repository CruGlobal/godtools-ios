//
//  GTLanguagesViewController.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Modified by Lee Braddock
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTLanguagesViewController.h"
#import "GTLanguageViewCell.h"
#import "GTStorage.h"
#import "GTLanguage.h"
#import "GTPackage.h"
#import "GTDataImporter.h"
#import "GTDefaults.h"

#import "GTGoogleAnalyticsTracker.h"

@interface GTLanguagesViewController() <GTLanguageViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *languages;
@property (strong, nonatomic) UIAlertView *buttonLessAlert;
@property AFNetworkReachabilityManager *afReachability;

- (void)updateFinished:(NSNotification *)notification;
- (void)updateFailed:(NSNotification *)notification;

@end

@implementation GTLanguagesViewController

GTLanguageViewCell *languageActionCell;

CGFloat cellSpacingHeight = 10.0;

NSString *languageDownloading = nil;
NSString *languageDownloadFailed = nil;
GTLanguage *selectedLanguage = nil;

BOOL languageDownloadCancelled = NO;

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([GTDefaults sharedDefaults].isChoosingForMainLanguage){
        [self setTitle : NSLocalizedString(@"menu_item_languages", nil)];
    }else{
        [self setTitle : NSLocalizedString(@"menu_item_languages", nil)];
    }

    [self setData];

    self.buttonLessAlert        = [[UIAlertView alloc]
                                   initWithTitle:@""
                                   message:@""
                                   delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:nil, nil];
    
    // set navigation bar title color for title set from story board
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GT4_HomeScreen_Background_ip5.png"]] ];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    self.afReachability = [AFNetworkReachabilityManager managerForDomain:@"www.google.com"];
    [self.afReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status < AFNetworkReachabilityStatusReachableViaWWAN) {
            NSLog(@"No internet connection!");
        }
    }];
	
    if([@"finished" isEqualToString:[[GTDefaults sharedDefaults] translationDownloadStatus]]) {
        languageDownloading = nil;
    }
    
    [[[GTGoogleAnalyticsTracker sharedInstance] setScreenName:@"LanguagesScreen"] sendScreenView];
    
    [self.afReachability startMonitoring];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.afReachability stopMonitoring];
}

- (void)setData {
    // fetch the current array of all languages and sort them by name
    self.languages = [[[GTStorage sharedStorage] fetchArrayOfModels:[GTLanguage class]
                                                       inBackground:YES]
                      sortedArrayUsingSelector:@selector(compare:)].mutableCopy;
    
    // if selecting parallel language, remove main language from the list
    if(![GTDefaults sharedDefaults].isChoosingForMainLanguage) {
		
		GTLanguage *main = [[GTStorage sharedStorage] languageWithCode:[GTDefaults sharedDefaults].currentLanguageCode];
		if (main) {
			[self.languages removeObject:main];
		}
		
    }
    
    if([[GTDefaults sharedDefaults] isInTranslatorMode] == [NSNumber numberWithBool:YES]){
        // if in preivew mode, only show languages that have at least one package
        self.languages = [self.languages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"packages.@count >= 0"]].mutableCopy;
    } else {
        // if not preview mode, only show languages w/ at least one package that's live
        self.languages = [self.languages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"packages.@count > 0 AND ANY packages.status == %@",@"live"]].mutableCopy;
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.languages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return cellSpacingHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), cellSpacingHeight)];
    [header setBackgroundColor:[UIColor clearColor]];
    return header;
}

- (BOOL) isSelectedLanguage:(GTLanguage *)language {
    return ([GTDefaults sharedDefaults].isChoosingForMainLanguage
            && [language.code isEqual:[[GTDefaults sharedDefaults]currentLanguageCode]])
            ||
            (![GTDefaults sharedDefaults].isChoosingForMainLanguage
             && [language.code isEqual:[[GTDefaults sharedDefaults]currentParallelLanguageCode]]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    GTLanguageViewCell *cell = (GTLanguageViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GTLanguageViewCell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GTLanguageViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.delegate = self;
    
    GTLanguage *language = [self.languages objectAtIndex:indexPath.section];

    [cell configureWithLanguage:language];
    [cell setIsSelected:[self isSelectedLanguage:language]];
    
    if ([language.code isEqualToString:languageDownloading]) {
        languageActionCell = cell;
        [languageActionCell setIsDownloading:YES];
    }

    return cell;
}

- (BOOL)ableToDownloadLanguageAtCell:(GTLanguageViewCell *)cell {
    GTLanguage *language = cell.language;
    
    if (language == nil) {
        return NO;
    }
    
    // don't take any action if we are currently downloading some other language
    if(([languageDownloading length] != 0) && ![languageDownloading isEqualToString:language.code]) {
        
        UIAlertView *cantDownloadAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"one_language_at_a_time_title", nil)
                                                                    message:NSLocalizedString(@"one_language_at_a_time_body", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                          otherButtonTitles:nil, nil];
        [cantDownloadAlert show];
        
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // don't allow row selection during download
    if ([languageDownloading length] != 0) {
        return;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    languageActionCell = (GTLanguageViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [self downloadLanguage];
}

#pragma mark - Convenience methods
- (void)setLanguageCodeInDefaults:(NSString *)code {
    if ([GTDefaults sharedDefaults].isChoosingForMainLanguage) {
        [[GTDefaults sharedDefaults]setCurrentLanguageCode:code];
    } else {
        [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:code];
    }
}

- (void)downloadLanguage {
    GTLanguage *chosen = languageActionCell.language;
    if ([chosen.downloaded boolValue] && !chosen.hasUpdates) {
        [self setLanguageCodeInDefaults:chosen.code];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([self ableToDownloadLanguageAtCell:languageActionCell]) {
        __weak typeof(self) weakSelf = self;
        
        // set state so that we know which language is being downloaded.
        languageDownloading = chosen.code.copy;
        languageDownloadCancelled = NO;
        [[GTDefaults sharedDefaults] setTranslationDownloadStatus:@"running"];
        
        // shows the UI download indicator
        [languageActionCell setIsDownloading:YES];
        
        // do the download/import
        [[GTDataImporter sharedImporter] downloadPromisedPackagesForLanguage:chosen].then(^{
            
            [weakSelf setLanguageCodeInDefaults:chosen.code];
            
            // so as to show check mark on selected language
            [self.tableView reloadData];
            
            //once language is selected go back to settings page
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }).catch(^(NSError *error) {
            
        }).finally(^{
            // reset state so a new download can happen
            languageDownloading = nil;
            
            // hide the UI download indicator
            [languageActionCell setIsDownloading:NO];
        });
    }
}
#pragma mark - API status/progress listener methods

-(void)languageDownloadProgressMade{
    [languageActionCell setIsDownloading:YES];
}

- (void)languageDownloadFinished {
    languageDownloading = nil;
    languageDownloadFailed = nil;
    [languageActionCell setIsDownloading:NO];
    [self setData];
    
    //once language is selected go back to settings page
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)languageDownloadFailed {
    languageDownloadFailed = selectedLanguage.code.copy;
    languageDownloading = nil;
    [languageActionCell setIsDownloading:NO];
    
    
    [self setData];
}

- (void)updateStarted:(NSNotification *)notification {
    [languageActionCell setIsDownloading:YES];
}

- (void)updateFinished:(NSNotification *)notification {
    if (languageDownloading) {
        languageDownloading = nil;
        languageDownloadFailed = nil;
        [languageActionCell setIsDownloading:NO];
        [self setData];
    } else {
        
        UIAlertView *confirmationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"new_updates_completed_title", nil)
                                                                    message:NSLocalizedString(@"new_updates_completed_body", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
        [confirmationAlert show];
        
        [self setData];
    }
}

- (void)updateFailed:(NSNotification *)notification {
    if (languageDownloading) {
        languageDownloadFailed = selectedLanguage.code.copy;
        languageDownloading = nil;
        [languageActionCell setIsDownloading:NO];
        [self setData];
    } else {
        UIAlertView *confirmationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"new_updates_failed_title", nil)
                                                                    message:NSLocalizedString(@"new_updates_failed_body", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
        [confirmationAlert show];
        
        [self setData];
    }
}

#pragma mark- GTLanguageViewCellDelegate methods
- (void)languageViewCellDownloadButtonWasPressed:(id)sender {
    languageActionCell = sender;
    
    [self downloadLanguage];
}

-(void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

@end
