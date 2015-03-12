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


@interface GTHomeViewController ()

@property (strong, nonatomic) NSString *languageCode;
@property (strong, nonatomic) NSMutableArray *packagesWithNoDrafts;
@property (strong, nonatomic) GTViewController *godtoolsViewController;
@property (strong, nonatomic) GTHomeView *homeView;
@property (strong, nonatomic) GTLanguage *phonesLanguage;
@property (strong, nonatomic) UIAlertView *phonesLanguageAlert;
@property (strong, nonatomic) UIAlertView *draftsAlert;
@property (strong, nonatomic) UIAlertView *createDraftsAlert;

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
    //self.homeView.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.homeView.tableView.contentInset = UIEdgeInsetsZero;
    self.homeView.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.homeView.tableView.bounds.size.width, 0.01f)];
    self.homeView.tableView.tableFooterView = nil;
    
    [self.homeView.tableView setBounces:NO];
    [self.homeView.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self.homeView initDownloadIndicator];
    
    self.isRefreshing = NO;
    
    self.articles = [[NSMutableArray alloc]init];
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
    self.draftsAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Do you want to publish this draft?" delegate:self cancelButtonTitle:@"No, I just need to see it." otherButtonTitles:@"Yes, it's ready!", nil];
    
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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed: 0.0 green:0.5 blue:1.0 alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:YES]; // required for iOS7
    self.navigationController.navigationBar.topItem.title = nil;
    
    [self.navigationController setNavigationBarHidden:YES];
    
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
//        [self refreshButtonPressed];
    }else if ([notification.name isEqualToString:GTDataImporterNotificationLanguageDraftsDownloadFinished]){
        [[GTDataImporter sharedImporter]updateMenuInfo];
    }else if([notification.name isEqualToString:GTDataImporterNotificationMenuUpdateFinished]){
        //to avoid split seconds gap to enabling user interaction when downloading drafts
        //note: after downloading drafts, the menu is also downloaded
        if(self.isRefreshing)
            self.isRefreshing = NO;
    }
    //if(!self.isRefreshing){
        [self.homeView setUserInteractionEnabled:YES];
    //}
}

-(void)showDownloadIndicator:(NSNotification *) notification{

    [self.homeView setUserInteractionEnabled:NO];

#warning Optimize after all the features are done. Use userInfo.
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
}

-(void) deleteDraftButtonPressed:(NSString *)sectionIdentifier{
    self.selectedSectionNumber = sectionIdentifier;
}

-(void) createDraftButtonPressed:(NSString *)sectionIdentifier{
    self.selectedSectionNumber = sectionIdentifier;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(tableView == self.homeView.tableView){
        return self.articles.count;
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
    return 10.; // you can have your own choice, of course
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
        
        GTPackage *package = [self.articles objectAtIndex:indexPath.section];
        cell.titleLabel.text = package.name;
        
        NSString *imageFilePath = [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:package.icon];
        
        cell.icon.image = [UIImage imageWithContentsOfFile: imageFilePath];
        [cell setUpBackground:(indexPath.section % 2)];
        
        if([self.languageCode isEqualToString:@"am-ET"]){
            cell.titleLabel.font = [UIFont fontWithName:@"NotoSansEthiopic" size:cell.titleLabel.font.pointSize];
        }
        
        if([self isTranslatorMode] && self.selectedSectionNumber != nil && [self.selectedSectionNumber intValue] == indexPath.section) {
            cell.publishDeleteOptionsView.hidden = NO;
            [cell.showTranslatorOptionsButton.imageView setImage:[UIImage imageNamed:@"GT4_HomeScreen_DraftGripD_"]];
        } else {
            cell.publishDeleteOptionsView.hidden = YES;
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
        GTPackage *selectedPackage = [self.articles objectAtIndex:indexPath.section];
        [self loadRendererWithPackage:selectedPackage];
    }
}

#pragma mark - Data setter methods

-(void)setData{
    
    self.languageCode = [[GTDefaults sharedDefaults]currentLanguageCode];
    NSArray *languages = [[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:self.languageCode inBackground:YES];
    
    GTLanguage* mainLanguage = (GTLanguage*)[languages objectAtIndex:0];
    
    self.articles = [[mainLanguage.packages allObjects]mutableCopy];

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

- (NSMutableArray *)packagesWithNoDrafts{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@"draft"];
    NSArray *draftsCodes = [[self.articles filteredArrayUsingPredicate:predicate]valueForKeyPath:@"code"];
    
    predicate = [NSPredicate predicateWithFormat:@"status == %@ AND NOT (code IN %@)",@"live",draftsCodes];
    
    NSArray *filteredArray = [self.articles filteredArrayUsingPredicate:predicate];
    
    return [filteredArray mutableCopy];

}

#pragma mark - Utility methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView == self.phonesLanguageAlert){
        if (buttonIndex == 1) {
            [self setMainLanguageToPhonesLanguage];
        }
    }else if(alertView == self.draftsAlert){
        GTPackage *selectedPackage = [self.articles objectAtIndex:self.homeView.tableView.indexPathForSelectedRow.row];
        if(buttonIndex == 0){
            [self loadRendererWithPackage:selectedPackage];
        }else if(buttonIndex == 1){
            //publish draft
            [[GTDataImporter sharedImporter] publishDraftForLanguage:selectedPackage.language package:selectedPackage];
        }
    }else if(alertView == self.createDraftsAlert){
        if(buttonIndex > 0){
            GTPackage *selectedPackage = [[self packagesWithNoDrafts]objectAtIndex:buttonIndex-1];
            [[GTDataImporter sharedImporter]createDraftsForLanguage:selectedPackage.language package:selectedPackage];
        }
    }
}

- (BOOL) isTranslatorMode {
    return [[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES];
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

#pragma mark - GTAboutViewController Delegate

- (UIView *)viewOfPageViewController {
    return _godtoolsViewController.view;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
