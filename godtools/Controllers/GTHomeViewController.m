//
//  GTHomeViewController.m
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTHomeViewController.h"
#import "GTBaseView.h"
#import "GTHomeViewCell.h"
#import "GTLanguage.h"
#import "GTPackage.h"
#import "GTStorage.h"
#import "GTDataImporter.h"
#import "GTDefaults.h"
#import "GTConfig.h"
#import "EveryStudentController.h"
#import "GTGoogleAnalyticsTracker.h"

#import "GTFollowupViewController.h"
#import "GTFollowUpSubscription.h"
#import "FollowUpAPI.h"

NSString *const GTHomeViewControllerShareCampaignSource        = @"godtools-ios";
NSString *const GTHomeViewControllerShareCampaignMedium        = @"email";
NSString *const GTHomeViewControllerShareCampaignName          = @"app-sharing";

@interface GTHomeViewController ()

@property (strong, nonatomic) NSString *languageCode;
@property (strong, nonatomic) GTViewController *godtoolsViewController;
@property (strong, nonatomic) GTShareInfo *shareInfo;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *godtoolsTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *translatorModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pullToRefreshLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *refreshDraftsView;
@property (weak, nonatomic) IBOutlet UIImageView *setLanguageImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pickToolImageView;
@property (weak, nonatomic) IBOutlet UIView *instructionsOverlayView;
@property (weak, nonatomic) IBOutlet UILabel *shareInstructionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *toolInstructionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageInstructionsLabel;

@property (strong, nonatomic) GTLanguage *phonesLanguage;
@property (strong, nonatomic) UIAlertView *phonesLanguageAlert;
@property (strong, nonatomic) UIAlertView *draftsAlert;
@property (strong, nonatomic) UIAlertView *createDraftsAlert;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) EveryStudentController *everyStudentViewController;

@property  BOOL isRefreshing;
@property (strong, nonatomic) NSString *selectedSectionNumber;

- (void)dismissInstructions:(UITapGestureRecognizer *)gestureRecognizer;
- (IBAction)settingsButtonPressed:(id)sender;
- (IBAction)shareButtonPressed:(id)sender;
- (IBAction)refreshDraftsButtonDragged:(id)sender;

@end

@implementation GTHomeViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.godtoolsTitle.title = NSLocalizedString(@"app_name", nil);
	self.translatorModeLabel.text = NSLocalizedString(@"translator_mode", nil);
	self.pullToRefreshLabel.text = NSLocalizedString(@"pull_down_info", nil);
	self.shareInstructionsLabel.text = NSLocalizedString(@"intro_share_instructions", nil);
	self.toolInstructionsLabel.text = NSLocalizedString(@"intro_tool_instructions", nil);
	self.languageInstructionsLabel.text = NSLocalizedString(@"intro_language_instructions", nil);
	
    [self.navigationController setNavigationBarHidden:YES];
	
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
    [((GTBaseView *)self.view) initDownloadIndicator];
    
    self.isRefreshing = NO;
    
    self.articles = [[NSMutableArray alloc]init];
    //Used to compare with current language count
    GTLanguage* englishLanguage = [self getEnglishLanguage];
    self.englishArticles = [[englishLanguage.packages allObjects]mutableCopy];
    
    self.packagesWithNoDrafts = [[NSMutableArray alloc]init];
    
    self.languageCode = [[GTDefaults sharedDefaults]currentLanguageCode];
    [self setData];
    [self.tableView reloadData];
    
    if(self.shouldShowInstructions) {
		
		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInstructions:)];
		[self.instructionsOverlayView addGestureRecognizer:tapRecognizer];
		[self performSelector:@selector(dismissInstructions:) withObject:tapRecognizer afterDelay:4.0f];
		
    } else {
		
		self.instructionsOverlayView.hidden = YES;
		[self.instructionsOverlayView removeFromSuperview];
		
    }
	
    self.draftsAlert = [[UIAlertView alloc] initWithTitle:nil
												 message:NSLocalizedString(@"draft_publish_message", nil)
												delegate:self
									   cancelButtonTitle:NSLocalizedString(@"draft_publish_negative", nil)
									   otherButtonTitles:NSLocalizedString(@"draft_publish_confirm", nil), nil];
    
    [self checkPhonesLanguage];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed: 0.0 green:0.5 blue:1.0 alpha:1.0]];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)] &&
        [self.navigationController.navigationBar respondsToSelector:@selector(setTranslucent:)]) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
        [self.navigationController.navigationBar setTranslucent:YES]; // required for iOS7
    }
    
    self.navigationController.navigationBar.topItem.title = nil;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    if([self isTranslatorMode]) {
        self.iconImageView.image = [UIImage imageNamed:@"GT4_Home_BookIcon_PreviewMode_"];
        self.translatorModeLabel.hidden = NO;
        self.refreshDraftsView.hidden = NO;
    } else {
        self.iconImageView.image = [UIImage imageNamed:@"GT4_Home_BookIcon_"];
        self.translatorModeLabel.hidden = YES;
        self.refreshDraftsView.hidden = YES;
    }
    
    [self setData];

    if(![self languageHasLivePackages:[self getCurrentPrimaryLanguage]] && ![self isTranslatorMode]) {
        self.languageCode = @"en";
        [[GTDefaults sharedDefaults] setCurrentLanguageCode:@"en" ];
        [self setData];
    }
        
    [[[GTGoogleAnalyticsTracker sharedInstance] setScreenName:@"HomeScreen"] sendScreenView];
    
    [self unregisterFollowupListener];
    
    [self.tableView reloadData];
}

#pragma mark - Download packages methods
-(void)downloadFinished {
    [self setData];
    [self.tableView reloadData];

    self.isRefreshing = NO;

    if(!self.isRefreshing) {
        [self.view setUserInteractionEnabled:YES];
        [self.refreshControl endRefreshing];
    }
}

-(void)downloadFailed {
    self.isRefreshing = NO;
    [self.view setUserInteractionEnabled:YES];
    [self.refreshControl endRefreshing];
}

#pragma mark - Instruction selectors

- (void)dismissInstructions:(UITapGestureRecognizer *)gestureRecognizer {
	
	if (self.instructionsOverlayView.superview) {
		
		[UIView animateWithDuration:1.0 delay:0.0 options:0 animations:^{
			
			self.instructionsOverlayView.alpha = 0.0f;
			
		} completion:^(BOOL finished) {
			
			if (self.instructionsOverlayView.superview) {
				[self.instructionsOverlayView removeFromSuperview];
				self.instructionsOverlayView.hidden = YES;
                self.shouldShowInstructions = NO;
                
                 GTLanguage* currentLanguage = [self getCurrentPrimaryLanguage];
                //Display message if currentLanguage is not English
                if(![currentLanguage.code isEqualToString:@"en"] && currentLanguage.packages.count < self.englishArticles.count){
                    [self untranslatedPackageMessage];
                }
			}
			
		}];
		
	}
	
}

#pragma mark - Navigation Bar Button selectors

- (IBAction)settingsButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"homeToSettingsViewSegue" sender:self];
}

- (IBAction)shareButtonPressed:(id)sender {
	
	NSURL *baseShareUrl = [NSURL URLWithString:NSLocalizedString(@"app_share_link_base_link", nil)];
	GTShareInfo *shareInfo = [[GTShareInfo alloc] initWithBaseURL:baseShareUrl
													  packageCode:nil
													 languageCode:nil];
	[shareInfo setGoogleAnalyticsCampaign:GTHomeViewControllerShareCampaignName
								   source:GTHomeViewControllerShareCampaignSource
								   medium:GTHomeViewControllerShareCampaignMedium];
	shareInfo.addPackageInfo = NO;
	shareInfo.addCampaignInfo = NO;
	shareInfo.subject = NSLocalizedString(@"share_general_subject", nil);
	shareInfo.message = NSLocalizedString(@"share_general_message", nil);
	shareInfo.appName = NSLocalizedString(@"app_name", nil);
	GTShareViewController *shareViewController = [[GTShareViewController alloc] initWithInfo:shareInfo];
	
	[self presentViewController:shareViewController animated:YES completion:nil];
}

- (IBAction)refreshDraftsButtonDragged:(id)sender {
    [self refresh];
};

#pragma mark - Home View Cell Delegates

-(void) showTranslatorOptionsButtonPressed:(NSString *)sectionIdentifier{
    if([self.selectedSectionNumber isEqualToString:sectionIdentifier]){
        self.selectedSectionNumber = nil;
    } else {
        self.selectedSectionNumber = sectionIdentifier;
    }
    [self.tableView reloadData];
}

-(void) publishDraftButtonPressed:(NSString *)sectionIdentifier{
    self.selectedSectionNumber = sectionIdentifier;
    [self.draftsAlert show];
}

-(void) deleteDraftButtonPressed:(NSString *)sectionIdentifier{
    self.selectedSectionNumber = sectionIdentifier;
}

-(void) createDraftButtonPressed:(NSString *)sectionIdentifier{
    self.selectedSectionNumber = sectionIdentifier;
    GTPackage *selectedPackage = [self.packagesWithNoDrafts objectAtIndex:([sectionIdentifier intValue] - self.articles.count)];
    NSString *selectedPackageTitle = selectedPackage.name;
    self.createDraftsAlert = [[UIAlertView alloc] initWithTitle:selectedPackageTitle
														message:NSLocalizedString(@"draft_start_message", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"cancel", nil)
											  otherButtonTitles:NSLocalizedString(@"yes", nil), nil];

    [self.createDraftsAlert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(tableView == self.tableView){
        if(![self isTranslatorMode]) {
            //every student is included for every language so add to the count
            //so that the cell will be created properly
                return self.articles.count + 1;
        }
        else {
            NSInteger articlesCount = self.articles.count;
            NSInteger missingDraftsCount = self.packagesWithNoDrafts.count;
            NSInteger total = articlesCount + missingDraftsCount;
            return total;
        }
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tableView){
        return 1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 14.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.tableView){
        GTHomeViewCell *cell = (GTHomeViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GTHomeViewCell"];
        
        if (cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GTHomeViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        //rendering a missing package
        NSInteger currentSection = indexPath.section;
        
        if([self isTranslatorMode] && currentSection >= self.articles.count) {
            GTPackage *package = [self.packagesWithNoDrafts objectAtIndex:(indexPath.section - self.articles.count)];
            
            cell.titleLabel.text = package.name;

            [cell setUpBackground:(indexPath.section % 2) :YES :YES];
            
            cell.icon.image = nil;
            
            [cell.contentView.layer setBorderColor:[UIColor lightTextColor].CGColor];
            [cell.contentView.layer setBorderWidth:1.0f];
            
        } else if([self isTranslatorMode]){
            GTPackage *package = [self.articles objectAtIndex:indexPath.section];
            cell.titleLabel.text = package.name;
        
            cell.icon.image = [[GTFileLoader sharedInstance] imageWithFilename:package.icon];
            [cell setUpBackground:(indexPath.section % 2) :YES :NO];
            
            [cell.contentView.layer setBorderColor:nil];
            [cell.contentView.layer setBorderWidth:0.0];
            
        } else if(currentSection >= self.articles.count){
            //block for every student cell
			cell.titleLabel.text = @"Questions About God?"; //only appears in english list so shouldn't be translated
            [cell setUpBackground:(indexPath.section % 2) :NO :NO];
            
            cell.icon.image = [UIImage imageNamed:@"EveryStudent4.2Icon.png"];
        } else {
            GTPackage *package = [self.articles objectAtIndex:indexPath.section];

            cell.titleLabel.text = package.name;
            
            cell.icon.image = [[GTFileLoader sharedInstance] imageWithFilename:package.icon];
            [cell setUpBackground:(indexPath.section % 2) :NO :NO];
            
            [cell.contentView.layer setBorderColor:nil];
            [cell.contentView.layer setBorderWidth:0.0];
            
        }
        
        if([self.languageCode isEqualToString:@"am-ET"]){
            cell.titleLabel.font = [UIFont fontWithName:@"NotoSansEthiopic" size:cell.titleLabel.font.pointSize];
        }
        
        if([self isTranslatorMode] && self.selectedSectionNumber != nil && [self.selectedSectionNumber intValue] == indexPath.section) {
            if([self.selectedSectionNumber intValue] >= self.articles.count) {
                cell.createOptionsView.hidden = NO;
            } else {
                cell.publishDeleteOptionsView.hidden = NO;
            }
            cell.verticalLayoutConstraint.constant = 33.0;
            if([self.selectedSectionNumber intValue] >= self.articles.count) {
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GT4_HomeScreen_PreviewCell_Missing_Bkgd.png"]];
            } else {
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GT4_HomeScreen_PreviewCell_Bkgd.png"]];
            }
            cell.backgroundColor = [UIColor clearColor];
        } else if([self isTranslatorMode]){
            cell.publishDeleteOptionsView.hidden = YES;
            cell.createOptionsView.hidden = YES;
            cell.verticalLayoutConstraint.constant = 2.0;
            cell.backgroundView = nil;
        } else {
            cell.publishDeleteOptionsView.hidden = YES;
            cell.createOptionsView.hidden = YES;
            cell.verticalLayoutConstraint.constant = 2.0;
            cell.backgroundView = nil;
        }
      
        
        cell.showTranslatorOptionsButton.hidden = ![self isTranslatorMode];
        cell.delegate = self;
        cell.sectionIdentifier = [@(indexPath.section) stringValue];
        
        return cell;
    }
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.tableView){
        if([self isTranslatorMode] &&
           self.selectedSectionNumber != nil &&
           [self.selectedSectionNumber intValue] == indexPath.section) {
         return 115;
        }
        else{
         return 53;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.tableView){
        if(indexPath.section < self.articles.count) {
            GTPackage *selectedPackage = [self.articles objectAtIndex:indexPath.section];
            [self loadRendererWithPackage:selectedPackage];
            [self registerFollowupListener];
            [self.navigationController pushViewController:self.godtoolsViewController animated:YES];

        } else if(![self isTranslatorMode] && indexPath.section == self.articles.count) {
            [self everyStudentViewController];
            
            self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
            
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            self.everyStudentViewController.language = @"en"; // for now, always English
            self.everyStudentViewController.package = @"everystudent";
            [self.navigationController pushViewController:self.everyStudentViewController animated:YES];
        }
    }
}

#pragma mark - Data setter methods
- (GTLanguage *) getCurrentPrimaryLanguage {
    return [[GTStorage sharedStorage] findClosestLanguageTo:self.languageCode];
}

- (GTLanguage *) getEnglishLanguage{
    return [[GTStorage sharedStorage] findClosestLanguageTo:@"en"];
}

- (void)setData {
    
    self.languageCode = [GTDefaults sharedDefaults].currentLanguageCode;
    
    GTLanguage* mainLanguage = [self getCurrentPrimaryLanguage];
    
    self.articles = [[mainLanguage.packages allObjects]mutableCopy];
    
    NSPredicate *missingDraftsPredicate = [NSPredicate predicateWithFormat:@"status == %@",@"draft"];
    NSArray *draftsCodes = [[self.articles filteredArrayUsingPredicate:missingDraftsPredicate]valueForKeyPath:@"code"];
    
    missingDraftsPredicate = [NSPredicate predicateWithFormat:@"status == %@ AND NOT (code IN %@)",@"live",draftsCodes];
    
    self.packagesWithNoDrafts = [[self.articles filteredArrayUsingPredicate:missingDraftsPredicate] mutableCopy];

    NSPredicate *predicate;
    
    if(![self isTranslatorMode]){
        predicate = [NSPredicate predicateWithFormat:@"status == %@",@"live"];
        
    } else {
       predicate = [NSPredicate predicateWithFormat:@"status == %@",@"draft"];
    }

    NSArray *filteredArray = [self.articles filteredArrayUsingPredicate:predicate];
    self.articles =  filteredArray.count > 0 ? [filteredArray mutableCopy] : nil;

    predicate = [NSPredicate predicateWithFormat:@"configFile != nil"];
    self.articles = [[self.articles filteredArrayUsingPredicate:predicate]mutableCopy];
    
    [self.articles sortUsingDescriptors:
     [NSArray arrayWithObjects:
      [NSSortDescriptor sortDescriptorWithKey:@"status" ascending:NO],
      [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]];
    
    if(![self isTranslatorMode]){
        predicate = [NSPredicate predicateWithFormat:@"status == %@ AND configFile != nil",@"live"];
        self.englishArticles =  [[self.englishArticles filteredArrayUsingPredicate:predicate]mutableCopy];
        [self.englishArticles sortUsingDescriptors:
         [NSArray arrayWithObjects:
          [NSSortDescriptor sortDescriptorWithKey:@"status" ascending:NO],
          [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]];
    
        if(self.articles.count < self.englishArticles.count)
        {
            [self untranslatedPackageMessage];
            __block BOOL same = NO;
            [self.englishArticles enumerateObjectsUsingBlock:^(GTPackage *enPackage, NSUInteger enIndex, BOOL *enStop){
                same = NO;
                [self.articles enumerateObjectsUsingBlock:^(GTPackage *package, NSUInteger index, BOOL *stop){
                    if([package.code isEqualToString: enPackage.code]){
                        same = YES;
                        *stop = YES;
                    }
                }];
                if(!same){
                    [self.articles addObject:enPackage];
                }
            }];
        }
    }
}

- (void)untranslatedPackageMessage{
    
    if(!self.shouldShowInstructions && ![[NSUserDefaults standardUserDefaults] valueForKey:@"missingLanguageAlertHasDisplayed"]){
        UIAlertView *missingPackagesAlert = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"less_packages_notification", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"missingLanguageAlertHasDisplayed"];
        [missingPackagesAlert show];
    }
}

#pragma mark - Language Methods
- (void)checkPhonesLanguage {
    if([[GTDefaults sharedDefaults] languagePromptHasBeenShown] == [NSNumber numberWithBool:YES]) {
        return;
    }
    
	GTLanguage *phonesLanguage = [[GTStorage sharedStorage] findClosestLanguageTo:[GTDefaults sharedDefaults].phonesLanguageCode];
	NSString *currentLanguageCode = [GTDefaults sharedDefaults].currentLanguageCode;
	BOOL translatorMode = [GTDefaults sharedDefaults].isInTranslatorMode.boolValue;
	
	if( ![phonesLanguage.code isEqualToString:currentLanguageCode]){
		
		if ( ( !translatorMode && [self languageHasLivePackages:phonesLanguage] ) ||
			 (  translatorMode && phonesLanguage.packages.count > 0 ) ) {
			
			self.phonesLanguage = phonesLanguage;
			NSString *message = [NSLocalizedString(@"language_alert_body", nil) stringByReplacingOccurrencesOfString:@"{{language_name}}" withString:self.phonesLanguage.name];
			self.phonesLanguageAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"language_alert_title", nil)
																  message:message
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"no", nil)
														otherButtonTitles:nil];
			[self.phonesLanguageAlert addButtonWithTitle:NSLocalizedString(@"yes", nil)];
			
			[self.view setUserInteractionEnabled:YES];
			[self.phonesLanguageAlert show];
            
            [[GTDefaults sharedDefaults] setLanguagePromptHasBeenShown:[NSNumber numberWithBool:YES]];
		}
	}
}

-(BOOL) languageHasLivePackages : (GTLanguage *)currentLanguage {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@"live"];
    NSArray *livePackages = [[currentLanguage.packages allObjects] filteredArrayUsingPredicate:predicate];
    
    return livePackages.count>0;
}

-(void)setMainLanguageToPhonesLanguage{
    GTLanguage *language = [[GTStorage sharedStorage] findClosestLanguageTo:[GTDefaults sharedDefaults].phonesLanguageCode];
    
    if(language.downloaded){
        [GTDefaults sharedDefaults].currentLanguageCode = language.code;
        if([[GTDefaults sharedDefaults].currentParallelLanguageCode isEqualToString:language.code]){
           [GTDefaults sharedDefaults].currentParallelLanguageCode = nil;
        }
        [self setData];
        [self.tableView reloadData];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDownloadProgressMade
                                                            object:self
                                                          userInfo:nil];
        [GTDefaults sharedDefaults].isChoosingForMainLanguage = YES;
        [[GTDataImporter sharedImporter]downloadPromisedPackagesForLanguage:language];
    }
}

#pragma mark - Followup methods
- (void)handleFollowupSubscription:(NSNotification *)notification {
    NSString *emailAddress = notification.userInfo[GTFollowupViewControllerFieldKeyEmail];
    NSString *name = notification.userInfo[GTFollowupViewControllerFieldKeyName];
//    NSString *followupId = notification.userInfo[@"org.cru.godtools.GTFollowupModalView.fieldKeyFollowupId"];
    
    __block GTFollowUpSubscription *subscription = [[GTFollowUpSubscription alloc] createNewSubscriptionForEmail:emailAddress
                                                                                                         forName:name
                                                                                                      inLanguage:self.languageCode
                                                                                                         toRoute:[[GTConfig sharedConfig] followUpApiDefaultRouteId]];
    
    [[FollowUpAPI sharedAPI] sendNewSubscription:subscription
                   onSuccess:^(AFHTTPRequestOperation *request, id obj) {
                       [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *context){
                           subscription.apiTransmissionSuccess = @YES;
                           subscription.apiTransmissionTimestamp = [NSDate date];
                       }
                                                                  completion:nil];
                   }
                   onFailure:^(AFHTTPRequestOperation *request, NSError *error) {
                       [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *context){
                           subscription.apiTransmissionSuccess = @NO;
                           subscription.apiTransmissionTimestamp = [NSDate date];
                       }
                                                                  completion:nil];
                   }];
}

#pragma mark - Utility methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView == self.phonesLanguageAlert){
        if (buttonIndex == 1) {
            [self setMainLanguageToPhonesLanguage];
        }
    }else if(alertView == self.draftsAlert){
        if(buttonIndex == 1){
            //publish draft
            GTPackage *selectedPackage = [self.articles objectAtIndex:[self.selectedSectionNumber intValue]];
            [[GTDataImporter sharedImporter] publishDraftForLanguage:selectedPackage.language package:selectedPackage];
        }
    }else if(alertView == self.createDraftsAlert){
        if(buttonIndex > 0){
            GTPackage *selectedPackage = [[self packagesWithNoDrafts]objectAtIndex:([self.selectedSectionNumber intValue] - self.articles.count)];
            [[GTDataImporter sharedImporter]createDraftsForLanguage:selectedPackage.language package:selectedPackage];
        }
    }
}

- (BOOL) isTranslatorMode {
    return [[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES];
}

-(void) refresh {
    GTLanguage *current = [[[GTStorage sharedStorage] fetchModel:[GTLanguage class]
                                                        usingKey:@"code"
                                                        forValue:[[GTDefaults sharedDefaults] currentLanguageCode] inBackground:YES] objectAtIndex:0];
    
    [[GTDefaults sharedDefaults]setIsChoosingForMainLanguage:YES];
    
    __weak typeof(self) weakSelf = self;
    
    [[GTDataImporter sharedImporter]downloadPromisedPackagesForLanguage:current].then(^{
        [[GTDataImporter sharedImporter] updateMenuInfo];
    }).catch(^{
        [weakSelf downloadFailed];
    }).finally(^{
        [weakSelf downloadFinished];
    });
}
#pragma mark - Renderer methods
-(void)loadRendererWithPackage: (GTPackage *)package{
	
	GTPackage *parallelPackage;
    BOOL isDraft = [package.status isEqualToString:@"draft"]? YES: NO;
    
    //add checker if parallel language has a package
    if([[GTDefaults sharedDefaults]currentParallelLanguageCode] != nil ){
        
        NSArray *languages = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[[[GTDefaults sharedDefaults]currentParallelLanguageCode]] inBackground:NO];
        if(languages){
            GTLanguage *parallelLanguage = [languages objectAtIndex:0];
            for(GTPackage *currentPackage in parallelLanguage.packages){
                if ([currentPackage.code isEqualToString:package.code] && [currentPackage.status isEqualToString:package.status]) {
                // workaround to pass a parallel  config file that is not nil. this is due to packages created with no config file
					if(currentPackage.configFile) {
                        parallelPackage = currentPackage;
					}
                }
            }
        }
    }

    self.godtoolsViewController.currentPackage = package;

	[self.godtoolsViewController setPackageCode:package.code languageCode:package.language.code];
	self.shareInfo.packageName = package.name;
	[self.godtoolsViewController setParallelPackageCode:parallelPackage.code parallelLanguageCode:parallelPackage.language.code];
    [self.godtoolsViewController addNotificationObservers];
        
    [self.godtoolsViewController loadResourceWithConfigFilename:package.configFile parallelConfigFileName:parallelPackage.configFile isDraft:isDraft];
}

#pragma  mark - GodToolsViewController

- (GTViewController *)godtoolsViewController {
    
    if (!_godtoolsViewController) {
        
        GTPackage *package = [self.articles objectAtIndex:0];
        GTFileLoader *fileLoader = [GTFileLoader fileLoader];
        fileLoader.language		= self.languageCode;
		
		NSURL *baseShareUrl = [NSURL URLWithString:NSLocalizedString(@"app_share_link_base_link", nil)];
		self.shareInfo = [[GTShareInfo alloc] initWithBaseURL:baseShareUrl
														  packageCode:@"kgp"
														 languageCode:@"en"];
		[self.shareInfo setGoogleAnalyticsCampaign:GTHomeViewControllerShareCampaignName
									   source:GTHomeViewControllerShareCampaignSource
									   medium:GTHomeViewControllerShareCampaignMedium];
		self.shareInfo.addPackageInfo = YES;
		self.shareInfo.addCampaignInfo = NO;
		self.shareInfo.subject = NSLocalizedString(@"share_from_page_subject", nil);
		self.shareInfo.message = NSLocalizedString(@"share_from_page_message", nil);
		self.shareInfo.appName = NSLocalizedString(@"app_name", nil);
        GTPageMenuViewController *pageMenuViewController = [[GTPageMenuViewController alloc] initWithFileLoader:fileLoader];
        GTAboutViewController *aboutViewController = [[GTAboutViewController alloc] initWithDelegate:self fileLoader:fileLoader];
        
        [self willChangeValueForKey:@"godtoolsViewController"];
        _godtoolsViewController	= [[GTViewController alloc] initWithConfigFile:package.configFile
																		 frame:self.view.frame
																   packageCode:@"kgp"
																  langaugeCode:@"en"
																	fileLoader:fileLoader
																	 shareInfo:self.shareInfo
                                                        pageMenuViewController:pageMenuViewController
                                                           aboutViewController:aboutViewController
                                                                      delegate:self];
        [self didChangeValueForKey:@"godtoolsViewController"];
        
    }
    
    return _godtoolsViewController;
}

#pragma  mark - EveryStudentController
- (EveryStudentController *)everyStudentViewController {
    
    if (!_everyStudentViewController) {
        [self willChangeValueForKey:@"everyStudentViewController"];
        _everyStudentViewController	= [[EveryStudentController alloc] initWithNibName:@"EveryStudentController" bundle:nil];
        [self didChangeValueForKey:@"everyStudentViewController"];
        
    }
    
    return _everyStudentViewController;
}

#pragma mark - GTAboutViewController Delegate

- (UIView *)viewOfPageViewController {
    return _godtoolsViewController.view;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)registerFollowupListener {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFollowupSubscription:)
                                                 name:@"org.cru.godtools.GTFollowupModalView.followupSubscriptionNotificationName"
                                               object:nil];
}

- (void)unregisterFollowupListener {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"org.cru.godtools.GTFollowupModalView.followupSubscriptionNotificationName"
                                               object:nil];

}
@end
