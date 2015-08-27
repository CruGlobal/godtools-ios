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
#import "GTLanguage+Helper.h"
#import "GTPackage+Helper.h"
#import "GTDataImporter.h"
#import "GTDefaults.h"

#import "GTGoogleAnalyticsTracker.h"

@interface GTLanguagesViewController ()
    @property (strong,nonatomic) NSMutableArray *languages;
    @property (strong, nonatomic) UIAlertView *buttonLessAlert;
    @property AFNetworkReachabilityManager *afReachability;
@end

@implementation GTLanguagesViewController

GTLanguageViewCell *languageActionCell;

CGFloat cellSpacingHeight = 10.;

NSString *languageDownloading = nil;
NSString *languageDownloadFailed = nil;
GTLanguage *selectedLanguage = nil;

BOOL languageDownloadCancelled = FALSE;

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setData];
    
    if([GTDefaults sharedDefaults].isChoosingForMainLanguage){
        [self setTitle : NSLocalizedString(@"GTLanguages_language_title", nil)];
    }else{
        [self setTitle : NSLocalizedString(@"GTLanguages_parallelLanguage_title", nil)];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(languageDownloadProgressMade)
                                                 name: GTLanguageViewDataImporterNotificationLanguageDownloadProgressMade
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(languageDownloadFinished)
                                                 name: GTLanguageViewDataImporterNotificationLanguageDownloadFinished
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(languageDownloadFailed)
                                                 name: GTLanguageViewDataImporterNotificationLanguageDownloadFailed
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setData)
                                                 name:GTDataImporterNotificationMenuUpdateFinished
                                               object:nil];
    
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

-(void)viewDidAppear:(BOOL)animated{
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
    [self showLanguageDownloadIndicator];
}

- (void)languageDownloadFinished {
    languageDownloading = nil;
    languageDownloadFailed = nil;
    [self hideLanguageDownloadIndicator];
    [self setData];
}

- (void)languageDownloadFailed {
    languageDownloadFailed = selectedLanguage.code.copy;
    languageDownloading = nil;
    [self hideLanguageDownloadIndicator];
    [self setData];
}

- (void)showLanguageDownloadIndicator{
    if(![languageActionCell.activityIndicator isAnimating]) {
        [languageActionCell.activityIndicator startAnimating];
    }
}

- (void)hideLanguageDownloadIndicator{
    if([languageActionCell.activityIndicator isAnimating]) {
        [languageActionCell.activityIndicator stopAnimating];
    }
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
		predicate = [NSPredicate predicateWithFormat:@"packages.@count > 0"];
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
	
    UIView *header = [UIView new];
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
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GTLanguageViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    GTLanguage *language = [self.languages objectAtIndex:indexPath.section];
	
	[cell configureWithLanguage:language target:self selector:@selector(languageAction:)];
	
    if ([self isSelectedLanguage:language]) {
        cell.checkBox.hidden = NO;
    }
    
    if ([language.code isEqualToString:languageDownloading]) {
        languageActionCell = cell;
        [self showLanguageDownloadIndicator];
    }

    // show error icon if language download failed is this language, and this is the selected language, and we are not downloading now, and this was not a cancelled download
    if([languageDownloadFailed isEqualToString:language.code] && [selectedLanguage.code isEqualToString:language.code] && ([languageDownloading length] == 0) && !languageDownloadCancelled) {
        cell.checkBox.hidden = YES;
        cell.errorIcon.hidden = NO;
    }
    
    return cell;
}

- (void) languageAction:(UIButton *)button{
    NSLog(@"languageAction() start ...");

    GTLanguageViewCell *cell = ((GTLanguageViewCell*) button.superview);
    languageActionCell = cell;

    // don't take any action if we are currently downloading some other language
    if(([languageDownloading length] != 0) && ![languageDownloading isEqualToString:cell.language.code]) {
        return;
    }

    selectedLanguage = cell.language;

    if(cell != nil) {
        NSString *title = [button titleForState:UIControlStateNormal];
        
        NSLog(@"languageAction() language name %@, title label %@, title %@", cell.languageName.text, button.titleLabel, title);

        if (!cell.isDownloading) {
            [cell setDownloadingField:YES];
            if([self downloadLanguage:cell.language]) {
                [(UIButton *) cell.accessoryView setTitle:NSLocalizedString(@"GTLanguages_cell_cancelButton", nil) forState:UIControlStateNormal];
                languageActionCell.checkBox.hidden = YES;
                languageActionCell.errorIcon.hidden = YES;
            }
        }
        else {
            [cell setDownloadingField:NO];
            [[GTDataImporter sharedImporter] cancelDownloadPackagesForLanguage];
            languageDownloadCancelled = YES;
        }
    }
}

- (BOOL)downloadLanguage:(GTLanguage *)language {
    
    BOOL result = NO;
    
    if(self.afReachability.reachable) {
        
        // get GTLanguage from name
        if(language != nil) {
            NSLog(@"languageAction() got language %@", language.name);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GTLanguageViewDataImporterNotificationLanguageDownloadProgressMade
                                                                object:self
                                                              userInfo:nil];
            
            [[GTDataImporter sharedImporter] downloadPackagesForLanguage:language
                                                    withProgressNotifier:GTLanguageViewDataImporterNotificationLanguageDownloadProgressMade
                                                     withSuccessNotifier:GTLanguageViewDataImporterNotificationLanguageDownloadFinished
                                                     withFailureNotifier:GTLanguageViewDataImporterNotificationLanguageDownloadFailed];

            languageDownloading = language.code.copy;

            [[GTDefaults sharedDefaults] setTranslationDownloadStatus:@"running"];
            
            languageDownloadCancelled = NO;

            result = YES;
        }
        
    } else {
        self.buttonLessAlert.message = NSLocalizedString(@"GTLanguages_download_error_reachability_message", nil);
        [self.buttonLessAlert show];
        [self performSelector:@selector(dismissAlertView:) withObject:self.buttonLessAlert afterDelay:2.0];
    }
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"tableViewdidSelectRowAtIndexPath() language %@, %@", selectedLanguage.name, languageDownloading);

    // don't allow row selection during download
    if([languageDownloading length] != 0) {
        return;
    }
    
    selectedLanguage = [self.languages objectAtIndex:indexPath.section];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    // download language if not yet downloaded
    if(!selectedLanguage.downloaded) {
        languageActionCell = (GTLanguageViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if([self downloadLanguage:languageActionCell.language]) {
            [(UIButton *) languageActionCell.accessoryView setTitle:NSLocalizedString(@"GTLanguages_cell_cancelButton", nil) forState:UIControlStateNormal];
            
            languageActionCell.checkBox.hidden = YES;
            languageActionCell.errorIcon.hidden = YES;
        }
        return;
    }

    GTLanguage *chosen = (GTLanguage*)[self.languages objectAtIndex:indexPath.section];
    
    // set the current language selected
    if(![GTDefaults sharedDefaults].isChoosingForMainLanguage) {
        [[GTDefaults sharedDefaults]setCurrentLanguageCode:chosen.code];
    }else {
        NSLog(@"set as parallel: %@",chosen.code);
        [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:chosen.code];
    }
   
    // so as to show check mark on selected language
    [tableView reloadData];
}

-(void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}


@end
