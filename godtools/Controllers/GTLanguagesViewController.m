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

@property (strong, nonatomic) NSMutableArray *languages;
@property (strong, nonatomic) UIAlertView *buttonLessAlert;
@property (strong, nonatomic) UIBarButtonItem *updateAllButton;
@property AFNetworkReachabilityManager *afReachability;

- (void)addDownloadAccessoryViewToCell:(GTLanguageViewCell *)cell;
- (void)addUpdateAccessoryViewToCell:(GTLanguageViewCell *)cell;
- (UIButton *)buttonForAccessoryViewWithTitle:(NSString *)title;

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
        [self setTitle : @"Language"];
    }else{
        [self setTitle : @"Parallel Language"];
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
	
	__weak typeof(self)weakSelf = self;
	[[NSNotificationCenter defaultCenter] addObserverForName:GTDataImporterNotificationNewVersionsAvailable
													  object:self
													   queue:nil
												  usingBlock:^(NSNotification *note) {
													  weakSelf.navigationItem.rightBarButtonItem = weakSelf.updateAllButton;
												  }];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:GTDataImporterNotificationUpdateStarted
													  object:self
													   queue:nil
												  usingBlock:^(NSNotification *note) {
													  weakSelf.updateAllButton.enabled = NO;
												  }];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:GTDataImporterNotificationUpdateFinished
													  object:self
													   queue:nil
												  usingBlock:^(NSNotification *note) {
													  weakSelf.navigationItem.rightBarButtonItem = nil;
													  weakSelf.updateAllButton.enabled = YES;
												  }];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:GTDataImporterNotificationUpdateFailed
													  object:self
													   queue:nil
												  usingBlock:^(NSNotification *note) {
													  weakSelf.updateAllButton.enabled = YES;
												  }];
    
    self.buttonLessAlert        = [[UIAlertView alloc]
                                   initWithTitle:@""
                                   message:@""
                                   delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:nil, nil];
	
	self.updateAllButton		= [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"GTLanguage_toolbar_button_updateAll", nil)
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(updateAllLanguages)];
    
    // set navigation bar title color for title set from story board
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GT4_HomeScreen_Background_ip5.png"]] ];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(languageDownloadFinished)
                                                 name: GTDataImporterNotificationLanguageDraftsDownloadFinished
                                               object:nil];

    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GTDataImporterNotificationLanguageDraftsDownloadFinished
                                                  object:nil];
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
	if (language.hasUpdates) {
		
		[self addUpdateAccessoryViewToCell:cell];
		
	} else if(!language.downloaded) {
		
        [self addDownloadAccessoryViewToCell:cell];
		
    }
    
    return cell;
}

- (void)addDownloadAccessoryViewToCell:(GTLanguageViewCell *)cell {
    
    cell.accessoryView = [self buttonForAccessoryViewWithTitle:NSLocalizedString(@"Download", nil)];
}

- (void)addUpdateAccessoryViewToCell:(GTLanguageViewCell *)cell {
	
	cell.accessoryView = [self buttonForAccessoryViewWithTitle:NSLocalizedString(@"Update", nil)];
}

- (UIButton *)buttonForAccessoryViewWithTitle:(NSString *)title {
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(0.0f, 0.0f, 150.0f, 25.0f);
	
	[button setTitle:title
			forState:UIControlStateNormal];
	
	[button setTitleColor: [UIColor whiteColor]
				 forState:UIControlStateNormal];
	
	[button addTarget:self
			   action:@selector(languageAction:)
	 forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

- (void) languageAction:(UIButton *)button{
    NSLog(@"languageAction() start ...");

    GTLanguageViewCell *cell = ((GTLanguageViewCell*) button.superview);
    languageActionCell = cell;

    // don't take any action if we are currently downloading some other language
    if(([languageDownloading length] != 0) && ![languageDownloading isEqualToString:cell.languageName.text]) {
		
		UIAlertView *cantDownloadAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GTLanguage_error_oneLanguageAtATime_Title", nil)
																	message:NSLocalizedString(@"GTLanguage_error_oneLanguageAtATime_Message", nil)
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"OK", nil)
														  otherButtonTitles:nil, nil];
		[cantDownloadAlert show];
		
        return;
    }

    selectedLanguage = [self gtLanguageFromName:cell.languageName.text];

    if(cell != nil) {
        NSString *title = [button titleForState:UIControlStateNormal];
        
        NSLog(@"languageAction() language name %@, title label %@, title %@", cell.languageName.text, button.titleLabel, title);

        if (!cell.isDownloading) {
            [cell setDownloadingField:TRUE];
			
			if (selectedLanguage.hasUpdates) {
				
				if([self updateLanguage:selectedLanguage]) {
					[(UIButton *) cell.accessoryView setTitle:@"Cancel" forState:UIControlStateNormal];
					languageActionCell.checkBox.hidden = TRUE;
					languageActionCell.errorIcon.hidden = TRUE;
				}
				
			} else {
				
				if([self downloadLanguage:selectedLanguage]) {
					[(UIButton *) cell.accessoryView setTitle:@"Cancel" forState:UIControlStateNormal];
					languageActionCell.checkBox.hidden = TRUE;
					languageActionCell.errorIcon.hidden = TRUE;
				}
				
			}

        } else {
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

- (BOOL)downloadLanguage:(GTLanguage *)language {
	
    return [self ifOnline:^{
		
        if(language != nil) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GTLanguageViewDataImporterNotificationLanguageDownloadProgressMade
                                                                object:self
                                                              userInfo:nil];
            
            [[GTDataImporter sharedImporter] downloadPackagesForLanguage:language
                                                    withProgressNotifier:GTLanguageViewDataImporterNotificationLanguageDownloadProgressMade
                                                     withSuccessNotifier:GTLanguageViewDataImporterNotificationLanguageDownloadFinished
                                                     withFailureNotifier:GTLanguageViewDataImporterNotificationLanguageDownloadFailed];

            languageDownloading = language.name.copy;

            [[GTDefaults sharedDefaults] setTranslationDownloadStatus:@"running"];
            
            languageDownloadCancelled = FALSE;
        }
        
	}];
}

- (void)updateAllLanguages {
	
	[self ifOnline:^{
		
		[[GTDataImporter sharedImporter] updatePackagesWithNewVersions];
		
	}];
	
}

- (BOOL)updateLanguage:(GTLanguage *)language {
	
	return [self ifOnline:^{
		
		if(language != nil) {
			
			[[NSNotificationCenter defaultCenter] postNotificationName:GTLanguageViewDataImporterNotificationLanguageDownloadProgressMade
																object:self
															  userInfo:nil];
			
			[[GTDataImporter sharedImporter] updatePackagesForLanguage:language];
			
			languageDownloading = language.name.copy;
			
			[[GTDefaults sharedDefaults] setTranslationDownloadStatus:@"running"];
			
			languageDownloadCancelled = FALSE;
		}
		
	}];
}

- (BOOL)ifOnline:(void (^)(void))codeBlock {
	
	if (self.afReachability.reachable) {
		
		codeBlock();
		return YES;
		
	} else {
		
		self.buttonLessAlert.message = NSLocalizedString(@"GTLanguage_error_needToBeOnline_Message", nil);
		[self.buttonLessAlert show];
		[self performSelector:@selector(dismissAlertView:) withObject:self.buttonLessAlert afterDelay:2.0];
		return NO;
	}
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"tableViewdidSelectRowAtIndexPath() language %@, %@", selectedLanguage.name, languageDownloading);

    // don't allow row selection during download
    if([languageDownloading length] != 0) {
		
		UIAlertView *cantChangeLanguageAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GTLanguage_error_cantChangeDuringDownload_Title", nil)
																	message:NSLocalizedString(@"GTLanguage_error_cantChangeDuringDownload_Message", nil)
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"OK", nil)
														  otherButtonTitles:nil, nil];
		[cantChangeLanguageAlert show];
		
        return;
    }
	
    selectedLanguage = [self.languages objectAtIndex:indexPath.section];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    // download language if not yet downloaded
    if(!selectedLanguage.downloaded) {
        languageActionCell = (GTLanguageViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if([self downloadLanguage:selectedLanguage]) {
            [(UIButton *) languageActionCell.accessoryView setTitle:@"Cancel" forState:UIControlStateNormal];
            
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
