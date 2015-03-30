//
//  GTHomeViewController.m
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTHomeViewController.h"
#import "GTHomeViewCell.h"
#import "GTHomeView.h"
#import "GTLanguage+Helper.h"
#import "GTPackage+Helper.h"
#import "GTStorage.h"
#import "GTDataImporter.h"
#import "GTDefaults.h"
#import "EveryStudentController.h"


@interface GTHomeViewController ()

@property (strong, nonatomic) NSString *languageCode;
@property (strong, nonatomic) GTViewController *godtoolsViewController;
@property (strong, nonatomic) GTHomeView *homeView;
@property (strong, nonatomic) GTLanguage *phonesLanguage;
@property (strong, nonatomic) UIAlertView *phonesLanguageAlert;
@property (strong, nonatomic) UIAlertView *draftsAlert;
@property (strong, nonatomic) UIAlertView *createDraftsAlert;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) EveryStudentController *everyStudentViewController;

@property  BOOL isRefreshing;
@property (strong, nonatomic) NSString *selectedSectionNumber;

@end

@implementation GTHomeViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.homeView = (GTHomeView*) [[[NSBundle mainBundle] loadNibNamed:@"GTHomeView" owner:nil options:nil]objectAtIndex:0];
    self.homeView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view = self.homeView;
    
    self.homeView.delegate = self;
    self.homeView.tableView.delegate = self;
    self.homeView.tableView.dataSource = self;

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor greenColor];
    self.refreshControl.hidden = NO;
    self.refreshControl.layer.zPosition = 1000;
    [self.refreshControl addTarget:self.homeView.tableView action:@selector(setData) forControlEvents:UIControlEventValueChanged];
    
    [self.homeView.tableView addSubview:self.refreshControl];
    
    [self.homeView initDownloadIndicator];
    
    self.isRefreshing = NO;
    
    self.articles = [[NSMutableArray alloc]init];
    self.packagesWithNoDrafts = [[NSMutableArray alloc]init];
    
    self.languageCode = [[GTDefaults sharedDefaults]currentLanguageCode];
    [self setData];
    [self.homeView.tableView reloadData];
    
    NSLog(@"phone's :%@",[[GTDefaults sharedDefaults]phonesLanguageCode]);
    
    if([[GTDefaults sharedDefaults]phonesLanguageCode]){
        self.phonesLanguage = [[[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults]phonesLanguageCode] inBackground:YES]objectAtIndex:0];
        self.phonesLanguageAlert = [[UIAlertView alloc] initWithTitle:@"Language Settings"
                                                                message:[NSString stringWithFormat:@"Would you like to make %@ as the default language?",self.phonesLanguage.name]
                                                               delegate:self
                                                      cancelButtonTitle:@"NO"
                                                      otherButtonTitles:nil];
        [self.phonesLanguageAlert addButtonWithTitle:@"YES"];
    }
    self.draftsAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Do you want to publish this draft?" delegate:self cancelButtonTitle:@"No, not yet." otherButtonTitles:@"Yes, it's ready!", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(downloadFinished:)
                                                 name:GTDataImporterNotificationMenuUpdateFinished
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDownloadIndicator:)
                                                 name:GTDataImporterNotificationMenuUpdateStarted
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFinished:)
                                                 name: GTDataImporterNotificationLanguageDownloadFinished
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDownloadIndicator:)
                                                 name: GTDataImporterNotificationLanguageDownloadProgressMade
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDownloadIndicator:)
                                                 name: GTDataImporterNotificationLanguageDraftsDownloadStarted
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFinished:)
                                                 name: GTDataImporterNotificationLanguageDraftsDownloadFinished
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDownloadIndicator:)
                                                 name: GTDataImporterNotificationCreateDraftStarted
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshButtonPressed)
                                                 name: GTDataImporterNotificationCreateDraftSuccessful
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFinished:)
                                                 name: GTDataImporterNotificationCreateDraftFail
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDownloadIndicator:)
                                                 name: GTDataImporterNotificationPublishDraftStarted
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFinished:)
                                                 name: GTDataImporterNotificationPublishDraftSuccessful
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFinished:)
                                                 name: GTDataImporterNotificationPublishDraftFail
                                               object:nil];
    
    [self checkPhonesLanguage];
    
    // set navigation bar text and chevron color
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    // set navigation bar background color
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.67 green:0.93 blue:0.93 alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:NO]; // required for iOS7
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed: 0.0 green:0.5 blue:1.0 alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:YES]; // required for iOS7
    self.navigationController.navigationBar.topItem.title = nil;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    if([self isTranslatorMode]) {
        self.homeView.iconImageView.image = [UIImage imageNamed:@"GT4_Home_BookIcon_PreviewMode_"];
        self.homeView.translatorModeLabel.hidden = NO;
        self.homeView.refreshDraftsView.hidden = NO;
    } else {
        self.homeView.iconImageView.image = [UIImage imageNamed:@"GT4_Home_BookIcon_"];
        self.homeView.translatorModeLabel.hidden = YES;
        self.homeView.refreshDraftsView.hidden = YES;
    }
    [self setData];
    [self.homeView.tableView reloadData];
}

#pragma mark - Download packages methods
-(void)downloadFinished:(NSNotification *) notification{
    NSLog(@"NOTIFICATION: %@",notification.name);
    [self.homeView hideDownloadIndicator];

    [self setData];
    [self.homeView.tableView reloadData];
    
    if([notification.name isEqualToString: GTDataImporterNotificationPublishDraftSuccessful]){
        [self refreshDrafts];
    }else if ([notification.name isEqualToString:GTDataImporterNotificationLanguageDraftsDownloadFinished]){
        [[GTDataImporter sharedImporter] updateMenuInfo];
    }else if([notification.name isEqualToString:GTDataImporterNotificationMenuUpdateFinished]){
        self.isRefreshing = NO;
    }
    
    if(!self.isRefreshing) {
        [self.homeView setUserInteractionEnabled:YES];
    }
}

-(void)showDownloadIndicator:(NSNotification *) notification{

    [self.homeView setUserInteractionEnabled:NO];

    if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){
        self.isRefreshing = YES;
    }
    if([notification.name isEqualToString: GTDataImporterNotificationLanguageDownloadProgressMade]){
        [self.homeView showDownloadIndicatorWithLabel: [NSString stringWithFormat: NSLocalizedString(@"GTHome_status_updatingResources", nil),@""]];
    }else if([notification.name isEqualToString:GTDataImporterNotificationLanguageDraftsDownloadStarted]){
        [self.homeView showDownloadIndicatorWithLabel: NSLocalizedString(@"GTHome_status_updatingDrafts", nil)];
    }else if([notification.name isEqualToString:GTDataImporterNotificationCreateDraftStarted]){
        [self.homeView showDownloadIndicatorWithLabel: NSLocalizedString(@"GTHome_status_creatingDrafts", nil)];
    }else if([notification.name isEqualToString:GTDataImporterNotificationPublishDraftStarted]){
        [self.homeView showDownloadIndicatorWithLabel: NSLocalizedString(@"GTHome_status_publishingDrafts", nil)];
    }else if([notification.name isEqualToString:GTDataImporterNotificationMenuUpdateStarted]){
        [self.homeView showDownloadIndicatorWithLabel:[NSString stringWithFormat: NSLocalizedString(@"Updating menu...", @"update resources (with menu)")]];
    }
}

#pragma Home View Delegates

-(void)settingsButtonPressed{
    [self performSegueWithIdentifier:@"homeToSettingsViewSegue" sender:self];
}

-(void)refreshDraftsButtonDragged {
    [self refreshDrafts];
};

#pragma mark - Home View Cell Delegates

-(void) showTranslatorOptionsButtonPressed:(NSString *)sectionIdentifier{
    if([self.selectedSectionNumber isEqualToString:sectionIdentifier]){
        self.selectedSectionNumber = nil;
    } else {
        self.selectedSectionNumber = sectionIdentifier;
    }
    [self.homeView.tableView reloadData];
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
    self.createDraftsAlert = [[UIAlertView alloc]initWithTitle:selectedPackageTitle message:@"Create new draft?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];

    [self.createDraftsAlert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(tableView == self.homeView.tableView){
        if(![self isTranslatorMode]) {
            //every student is included for english only when not in translator mode, so add a cell
            if([self.languageCode isEqualToString:@"en"]) {
                return self.articles.count + 1;
            }
            return self.articles.count;
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
    if(tableView == self.homeView.tableView){
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
    
    if(tableView == self.homeView.tableView){
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
            
            NSString *imageFilePath = [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:package.icon];
        
            cell.icon.image = [UIImage imageWithContentsOfFile: imageFilePath];
            [cell setUpBackground:(indexPath.section % 2) :YES :NO];
            
            [cell.contentView.layer setBorderColor:nil];
            [cell.contentView.layer setBorderWidth:0.0];
        } else if(currentSection >= self.articles.count){
            //block for every student cell
            cell.titleLabel.text = @"Every Student";
            [cell setUpBackground:(indexPath.section % 2) :NO :NO];
            cell.icon.image = [UIImage imageNamed:@"GT4_HomeScreen_ESIcon_.png"];
        } else {
            GTPackage *package = [self.articles objectAtIndex:indexPath.section];
            cell.titleLabel.text = package.name;
            
            NSString *imageFilePath = [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:package.icon];
            
            cell.icon.image = [UIImage imageWithContentsOfFile: imageFilePath];
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
    if(tableView == self.homeView.tableView){
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
    if(tableView == self.homeView.tableView){
        if(indexPath.section < self.articles.count) {
            GTPackage *selectedPackage = [self.articles objectAtIndex:indexPath.section];
            [self loadRendererWithPackage:selectedPackage];
        } else if(![self isTranslatorMode] && indexPath.section == self.articles.count) {
            [self everyStudentViewController];
            
            self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
            
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            self.everyStudentViewController.language = @"en"; // for now, always English
            self.everyStudentViewController.package = @"EveryStudent"; // for lack of knowing what else to put
            [self.navigationController pushViewController:self.everyStudentViewController animated:YES];
        }
    }
}

#pragma mark - Data setter methods

-(void)setData{
    
    self.languageCode = [[GTDefaults sharedDefaults]currentLanguageCode];
    NSArray *languages = [[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:self.languageCode inBackground:YES];
    
    GTLanguage* mainLanguage = (GTLanguage*)[languages objectAtIndex:0];
    
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
    
}

#pragma mark - Language Methods
-(void)checkPhonesLanguage{
    
    GTLanguage *language = [[[GTStorage sharedStorage] fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults] phonesLanguageCode] inBackground:YES]objectAtIndex:0];
    
    BOOL shouldSetPhonesLanguageAsMainLanguage = ![[[GTDefaults sharedDefaults]phonesLanguageCode] isEqualToString:[[GTDefaults sharedDefaults] currentLanguageCode]];
    
    shouldSetPhonesLanguageAsMainLanguage = shouldSetPhonesLanguageAsMainLanguage && [[GTDefaults sharedDefaults]phonesLanguageCode]!=nil ;

    
    if([[GTDefaults sharedDefaults] isInTranslatorMode] == [NSNumber numberWithBool:NO]){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@"live"];
        NSArray *livePackages = [[language.packages allObjects] filteredArrayUsingPredicate:predicate];

        shouldSetPhonesLanguageAsMainLanguage = shouldSetPhonesLanguageAsMainLanguage && livePackages.count>0;
    }else if([[GTDefaults sharedDefaults] isInTranslatorMode] == [NSNumber numberWithBool:YES]){
        shouldSetPhonesLanguageAsMainLanguage = shouldSetPhonesLanguageAsMainLanguage && language.packages.count>0;
    }
    
    //phone's language is not the current main language of the app
    if(shouldSetPhonesLanguageAsMainLanguage){
            [self.homeView setUserInteractionEnabled:YES];
            [self.phonesLanguageAlert show];
    }
}

-(void)setMainLanguageToPhonesLanguage{
    GTLanguage *language = [[[GTStorage sharedStorage] fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults] phonesLanguageCode] inBackground:YES]objectAtIndex:0];
    
    if(language.downloaded){
        [[GTDefaults sharedDefaults]setCurrentLanguageCode:language.code];
        if([[[GTDefaults sharedDefaults]currentParallelLanguageCode] isEqualToString:language.code]){
           [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:nil];
        }
        [self setData];
        [self.homeView.tableView reloadData];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDownloadProgressMade
                                                            object:self
                                                          userInfo:nil];
        [[GTDefaults sharedDefaults] setIsChoosingForMainLanguage:[NSNumber numberWithBool:YES]];
        [[GTDataImporter sharedImporter]downloadPackagesForLanguage:language];
    }
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

-(void) refreshDrafts {
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadStarted object:self];
    GTLanguage *current = [[[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults] currentLanguageCode] inBackground:YES]objectAtIndex:0];
    [[GTDefaults sharedDefaults]setIsChoosingForMainLanguage:[NSNumber numberWithBool:YES]];
    [[GTDataImporter sharedImporter]downloadPackagesForLanguage:current];
}
#pragma mark - Renderer methods
-(void)loadRendererWithPackage: (GTPackage *)package{
   
    NSString *parallelConfigFile;
    BOOL isDraft = [package.status isEqualToString:@"draft"]? YES: NO;
    
    //add checker if parallel language has a package
    if([[GTDefaults sharedDefaults]currentParallelLanguageCode] != nil ){
        
        NSArray *languages = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[[[GTDefaults sharedDefaults]currentParallelLanguageCode]] inBackground:NO];
        if(languages){
            GTLanguage *parallelLanguage = [languages objectAtIndex:0];
            for(GTPackage *parallelPackage in parallelLanguage.packages){
                if ([parallelPackage.code isEqualToString:package.code] && [parallelPackage.status isEqualToString:package.status]) {
                // workaround to pass a parallel  config file that is not nil. this is due to packages created with no config file
                    if(parallelPackage.configFile)
                        parallelConfigFile = parallelPackage.configFile;
                }
            }
        }
    }

    self.godtoolsViewController.currentPackage = package;
    [self.godtoolsViewController addNotificationObservers];
        
    [self.godtoolsViewController loadResourceWithConfigFilename:package.configFile parallelConfigFileName:parallelConfigFile isDraft:isDraft];
    [self.navigationController pushViewController:self.godtoolsViewController animated:YES];
    
}

#pragma  mark - GodToolsViewController
- (GTViewController *)godtoolsViewController {
    
    if (!_godtoolsViewController) {
        
        GTPackage *package = [self.articles objectAtIndex:0];
        GTFileLoader *fileLoader = [GTFileLoader fileLoader];
        fileLoader.language		= self.languageCode;
        GTShareViewController *shareViewController = [[GTShareViewController alloc] init];
        GTPageMenuViewController *pageMenuViewController = [[GTPageMenuViewController alloc] initWithFileLoader:fileLoader];
        GTAboutViewController *aboutViewController = [[GTAboutViewController alloc] initWithDelegate:self fileLoader:fileLoader];
        
        [self willChangeValueForKey:@"godtoolsViewController"];
        _godtoolsViewController	= [[GTViewController alloc] initWithConfigFile:package.configFile
                                                                    fileLoader:fileLoader
                                                           shareViewController:shareViewController
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

@end
