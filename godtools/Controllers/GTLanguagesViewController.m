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

@interface GTLanguagesViewController ()

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

- (void)setData{
    self.languages = [[GTStorage sharedStorage] fetchArrayOfModels:[GTLanguage class] inBackground:YES].mutableCopy;
    
    NSArray *sortedArray;
    sortedArray = [self.languages sortedArrayUsingSelector:@selector(compare:)];
    
    self.languages = [sortedArray mutableCopy];
    
    if(![GTDefaults sharedDefaults].isChoosingForMainLanguage) {
		
		GTLanguage *main = [[GTStorage sharedStorage] languageWithCode:[GTDefaults sharedDefaults].currentLanguageCode];
		if (main) {
			[self.languages removeObject:main];
		}
		
    }
    
    NSPredicate *predicate = [[NSPredicate alloc]init];
    
    if([[GTDefaults sharedDefaults] isInTranslatorMode] == [NSNumber numberWithBool:YES]){
		predicate = [NSPredicate predicateWithFormat:@"packages.@count >= 0"];
    } else {
		predicate = [NSPredicate predicateWithFormat:@"packages.@count > 0 AND ANY packages.status == %@",@"live"];
    }
    
    self.languages = [self.languages filteredArrayUsingPredicate:predicate].mutableCopy;
    
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
    
    GTLanguage *language = [self.languages objectAtIndex:indexPath.section];

    [cell configureWithLanguage:language internetReachable:self.afReachability.reachable];
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

- (void)cancelDownloadForLanguageAtCell:(GTLanguageViewCell *)cell {
	
	[[GTDataImporter sharedImporter] cancelDownloadPackagesForLanguage];
	languageDownloadCancelled = YES;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // don't allow row selection during download
    if ([languageDownloading length] != 0) {
        return;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    GTLanguage *chosen = (GTLanguage*)[self.languages objectAtIndex:indexPath.section];
    languageActionCell = (GTLanguageViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
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
            
            // set the current language selected
            if ([GTDefaults sharedDefaults].isChoosingForMainLanguage) {
                [[GTDefaults sharedDefaults]setCurrentLanguageCode:chosen.code];
            } else {
                [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:chosen.code];
            }
            
            // so as to show check mark on selected language
            [tableView reloadData];
            
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

-(void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

@end
