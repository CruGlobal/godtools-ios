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
    
    if([[GTDefaults sharedDefaults] isChoosingForMainLanguage] == [NSNumber numberWithBool:YES]){
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
    languageDownloadFailed = selectedLanguage.name.copy;
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
    self.languages = [[[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] inBackground:YES]mutableCopy];
    
    NSArray *sortedArray;
    sortedArray = [self.languages sortedArrayUsingSelector:@selector(compare:)];
    
    self.languages = [sortedArray mutableCopy];
    
    
    
    if([[GTDefaults sharedDefaults] isChoosingForMainLanguage] == [NSNumber numberWithBool:NO]){
        GTLanguage *main = [[[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[[[GTDefaults sharedDefaults] currentLanguageCode]] inBackground:YES] objectAtIndex:0];
        
        [self.languages removeObject:main];
    }
    
    NSPredicate *predicate = [[NSPredicate alloc]init];
    
    if([[GTDefaults sharedDefaults] isInTranslatorMode] == [NSNumber numberWithBool:NO]){
        predicate = [NSPredicate predicateWithFormat:@"packages.@count > 0 AND ANY packages.status == %@",@"live"];
    }else if([[GTDefaults sharedDefaults] isInTranslatorMode] == [NSNumber numberWithBool:YES]){
        predicate = [NSPredicate predicateWithFormat:@"packages.@count > 0"];
    }
    
    self.languages = [[self.languages filteredArrayUsingPredicate:predicate]mutableCopy];
    
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

- (BOOL) isSelectedLanguage:(GTLanguage *)language {
    return ([[GTDefaults sharedDefaults] isChoosingForMainLanguage] == [NSNumber numberWithBool:YES]
            && [language.code isEqual:[[GTDefaults sharedDefaults]currentLanguageCode]])
            ||
            ([[GTDefaults sharedDefaults] isChoosingForMainLanguage] == [NSNumber numberWithBool:NO]
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
    
    cell.languageName.text = language.name;
    cell.languageName.textColor = [UIColor whiteColor];
    
    UIColor *semiTransparentColor = [UIColor colorWithRed:255 green:255 blue:255 alpha: .1];
    cell.backgroundColor = semiTransparentColor;
    
    cell.checkBox.hidden = TRUE;
    cell.errorIcon.hidden = TRUE;
    if([self isSelectedLanguage:language]) {
        cell.checkBox.hidden = FALSE;
    }
    
    if([language.name isEqualToString:languageDownloading]) {
        languageActionCell = cell;
        [self showLanguageDownloadIndicator];
    }

    // show error icon if language download failed is this language, and this is the selected language, and we are not downloading now, and this was not a cancelled download
    if([languageDownloadFailed isEqualToString:language.name] && [selectedLanguage.name isEqualToString:language.name] && ([languageDownloading length] == 0) && !languageDownloadCancelled) {
        cell.checkBox.hidden = TRUE;
        cell.errorIcon.hidden = FALSE;
    }
    
    // Create custom accessory view with action selector
    if(!language.downloaded) {
        [self addAccessoryView:cell];
    }
    
    return cell;
}

- (void)addAccessoryView:(GTLanguageViewCell *)cell {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0.0f, 0.0f, 150.0f, 25.0f);
    
    NSString *buttonTitle = NSLocalizedString(@"GTLanguages_cell_downloadButton", nil);
    cell.accessoryView = nil;
    
    [button setTitle:buttonTitle
            forState:UIControlStateNormal];
    
    [button setTitleColor: [UIColor whiteColor]
                 forState:UIControlStateNormal];
    
    [button addTarget:self
               action:@selector(languageAction:)
     forControlEvents:UIControlEventTouchUpInside];
    
    cell.accessoryView = button;
}

- (void) languageAction:(UIButton *)button{
    NSLog(@"languageAction() start ...");

    GTLanguageViewCell *cell = ((GTLanguageViewCell*) button.superview);
    languageActionCell = cell;

    // don't take any action if we are currently downloading some other language
    if(([languageDownloading length] != 0) && ![languageDownloading isEqualToString:cell.languageName.text]) {
        return;
    }

    selectedLanguage = [self gtLanguageFromName:cell.languageName.text];

    if(cell != nil) {
        NSString *title = [button titleForState:UIControlStateNormal];
        
        NSLog(@"languageAction() language name %@, title label %@, title %@", cell.languageName.text, button.titleLabel, title);

        if (!cell.isDownloading) {
            [cell setDownloadingField:TRUE];
            if([self downloadLanguage:cell.languageName.text]) {
                [(UIButton *) cell.accessoryView setTitle:NSLocalizedString(@"GTLanguages_cell_cancelButton", nil) forState:UIControlStateNormal];
                languageActionCell.checkBox.hidden = TRUE;
                languageActionCell.errorIcon.hidden = TRUE;
            }
        }
        else {
            [cell setDownloadingField:FALSE];
            [[GTDataImporter sharedImporter] cancelDownloadPackagesForLanguage];
            languageDownloadCancelled = TRUE;
        }
    }
}

- (GTLanguage *)gtLanguageFromName:(NSString *)languageName {
    for (GTLanguage *language in self.languages) {
        if([language.name isEqualToString:languageName]) {
            return language;
        }
    }
    return nil;
}

- (BOOL)downloadLanguage:(NSString *)languageName {
    
    BOOL result = FALSE;
    
    if(self.afReachability.reachable) {
        
        // get GTLanguage from name
        GTLanguage *gtLanguage = [self gtLanguageFromName:languageName];
        if(gtLanguage != nil) {
            NSLog(@"languageAction() got language %@", gtLanguage.name);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GTLanguageViewDataImporterNotificationLanguageDownloadProgressMade
                                                                object:self
                                                              userInfo:nil];
            
            [[GTDataImporter sharedImporter] downloadPackagesForLanguage:gtLanguage
                                                    withProgressNotifier:GTLanguageViewDataImporterNotificationLanguageDownloadProgressMade
                                                     withSuccessNotifier:GTLanguageViewDataImporterNotificationLanguageDownloadFinished
                                                     withFailureNotifier:GTLanguageViewDataImporterNotificationLanguageDownloadFailed];

            languageDownloading = languageName.copy;

            [[GTDefaults sharedDefaults] setTranslationDownloadStatus:@"running"];
            
            languageDownloadCancelled = FALSE;

            result = TRUE;
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
        if([self downloadLanguage:languageActionCell.languageName.text]) {
            [(UIButton *) languageActionCell.accessoryView setTitle:NSLocalizedString(@"GTLanguages_cell_cancelButton", nil) forState:UIControlStateNormal];
            
            languageActionCell.checkBox.hidden = TRUE;
            languageActionCell.errorIcon.hidden = TRUE;
        }
        return;
    }

    GTLanguage *chosen = (GTLanguage*)[self.languages objectAtIndex:indexPath.section];
    
    // set the current language selected
    if([[GTDefaults sharedDefaults] isChoosingForMainLanguage] == [NSNumber numberWithBool:YES]) {
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
