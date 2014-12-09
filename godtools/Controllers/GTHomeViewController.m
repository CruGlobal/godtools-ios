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
    self.homeView.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.homeView.tableView.contentInset = UIEdgeInsetsZero;
    self.homeView.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.homeView.tableView.bounds.size.width, 0.01f)];
    self.homeView.tableView.tableFooterView = nil;
    
    [self.homeView.tableView setBounces:NO];
    [self.homeView.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.homeView.tableView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.homeView.tableView.layer setBorderWidth:2.0f];
    [self.homeView.tableView.layer setCornerRadius:8.0f];

    [self.homeView initDownloadIndicator];
    
    self.articles = [[NSMutableArray alloc]init];
    self.languageCode = [[GTDefaults sharedDefaults]currentLanguageCode];
    [self setData];
    [self.homeView.tableView reloadData];
    
    self.phonesLanguage = [[[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults]phonesLanguageCode] inBackground:NO]objectAtIndex:0];
    self.phonesLanguageAlert = [[UIAlertView alloc] initWithTitle:@"Language Settings"
                                                            message:[NSString stringWithFormat:@"Would you like to make %@ as the default language?",self.phonesLanguage.name]
                                                           delegate:self
                                                  cancelButtonTitle:@"NO"
                                                  otherButtonTitles:nil];
    [self.phonesLanguageAlert addButtonWithTitle:@"YES"];
    
    self.draftsAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Do you want to publish this draft?" delegate:self cancelButtonTitle:@"No, I just need to see it." otherButtonTitles:@"Yes, it's ready!", nil];
    
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
    
    [self checkPhonesLanguage];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self setData];
    [self.homeView.tableView reloadData];

    if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:NO]){
        self.homeView.refreshButton.hidden = YES;
        self.homeView.addDraftButton.hidden = YES;
    }else if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){
        self.homeView.refreshButton.hidden = NO;
        self.homeView.addDraftButton.hidden = NO;
    }
}

#pragma mark - Download packages methods
-(void)downloadFinished:(NSNotification *) notification{

    if([self.homeView.activityView isAnimating]){
        [self.homeView hideDownloadIndicator];
    }

    [self setData];
    [self.homeView.tableView reloadData];
}

-(void)showDownloadIndicator:(NSNotification *) notification{
    //NSDictionary *userInfo = notification.userInfo;
#warning Optimize after all the features are done. Use userInfo.
    //NSLog(@" downloading %@",[userInfo objectForKey:GTDataImporterNotificationLanguageDownloadPercentageKey]);
    if([notification.name isEqualToString: GTDataImporterNotificationLanguageDownloadProgressMade]){
        self.homeView.loadingLabel.text = @"Updating Resources...";
    }else if([notification.name isEqualToString:GTDataImporterNotificationLanguageDraftsDownloadStarted]){
        self.homeView.loadingLabel.text = @"Downloading drafts";
    }else if([notification.name isEqualToString:GTDataImporterNotificationCreateDraftStarted])    {
        self.homeView.loadingLabel.text = @"Creating draft";
    }
    if(![self.homeView.activityView isAnimating]){
        [self.homeView showDownloadIndicator];
    }
}

#pragma Home View Delegates

-(void)settingsButtonPressed{
    [self performSegueWithIdentifier:@"homeToSettingsViewSegue" sender:self];
}

-(void)addDraftButtonPressed{
    //[self getPackagesWithNoDrafts];
    self.createDraftsAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Add draft?" delegate:self cancelButtonTitle:@"None" otherButtonTitles:nil, nil];
    for (GTPackage *package in [self packagesWithNoDrafts]) {
        [self.createDraftsAlert addButtonWithTitle:package.name];
    }
    [self.createDraftsAlert show];
}

-(void)refreshButtonPressed{
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadStarted object:self];
    GTLanguage *current = [[[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults] currentLanguageCode] inBackground:NO]objectAtIndex:0];
    [[GTDataImporter sharedImporter]downloadDraftsForLanguage:current];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(tableView == self.homeView.tableView){
        return 1;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.homeView.tableView){
        return self.articles.count;
    }
    
    return 0;
}

- (UITableViewHeaderFooterView *)headerViewForSection:(NSInteger)section{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.homeView.tableView){
        GTHomeViewCell *cell = (GTHomeViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GTHomeViewCell"];
        
        if (cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GTHomeViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        GTPackage *package = [self.articles objectAtIndex:indexPath.row];
        
        cell.titleLabel.text = package.name;
        cell.statusLabel.text = package.status;
        
        NSString *imageFilePath = [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:package.icon];
        
        cell.icon.image = [UIImage imageWithContentsOfFile: imageFilePath];
        [cell setUpBackground:(indexPath.row % 2)];
        
        //[cell setNeedsUpdateConstraints];
        //[cell updateConstraintsIfNeeded];
        return cell;
    }
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.homeView.tableView){
        return 44;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.homeView.tableView){
        GTPackage *selectedPackage = [self.articles objectAtIndex:indexPath.row];
        if([selectedPackage.status isEqualToString: @"live"]){
            [self loadRendererWithPackage:selectedPackage];
        }else{
            [self.draftsAlert show];
        }
        
        //[self.homeView.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

#pragma mark - Data setter methods

-(void)setData{
    
    self.languageCode = [[GTDefaults sharedDefaults]currentLanguageCode];
    NSArray *languages = [[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:self.languageCode inBackground:NO];
    
    GTLanguage* mainLanguage = (GTLanguage*)[languages objectAtIndex:0];
    
    self.articles = [[mainLanguage.packages allObjects]mutableCopy]
    ;
    

    if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:NO]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@"live"];
        
        //NSLog(@"predicate: %@",predicate);
        
        NSArray *filteredArray = [self.articles filteredArrayUsingPredicate:predicate];
        self.articles =  filteredArray.count > 0 ? [filteredArray mutableCopy] : nil;
    }
    //NSArray *sortedArray = [self.articles sortedArrayUsingSelector:@selector(compare:)];
    
    [self.articles sortUsingDescriptors:
     [NSArray arrayWithObjects:
      [NSSortDescriptor sortDescriptorWithKey:@"status" ascending:NO],
      [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]];
    
    //self.articles = [sortedArray mutableCopy];
}

#pragma mark - Language Methods
-(void)checkPhonesLanguage{

    if(![[[GTDefaults sharedDefaults]phonesLanguageCode] isEqualToString:[[GTDefaults sharedDefaults] currentLanguageCode]]){
        if ([UIAlertController class]){
            UIAlertController *languageAlert =[UIAlertController
                                               alertControllerWithTitle:@"Language Settings"
                                               message:[NSString stringWithFormat:@"Would you like to make %@ as the default language?",self.phonesLanguage.name ]
                                               preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"YES"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                    [self setMainLanguageToPhonesLanguage];
                                     [languageAlert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"NO"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [languageAlert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            
            [languageAlert addAction:ok];
            [languageAlert addAction:cancel];
            
            [self presentViewController:languageAlert animated:YES completion:nil];
        }else{
            //NSLog(@"!controller");
            [self.phonesLanguageAlert show];
        }
    }
    /*else if([[[GTDefaults sharedDefaults]phonesLanguageCode] isEqualToString:[[GTDefaults sharedDefaults] currentLanguageCode]]){
        //NSLog(@"current phone's language is the current app's main language");
    }*/
}

-(void)setMainLanguageToPhonesLanguage{
    GTLanguage *language = [[[GTStorage sharedStorage] fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults] phonesLanguageCode] inBackground:NO]objectAtIndex:0];
    
    if(language.downloaded){
        //NSLog(@"no need to download language");
        NSString *current = [[GTDefaults sharedDefaults]currentLanguageCode];
        [[GTDefaults sharedDefaults]setCurrentLanguageCode:language.code];
        [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:current];
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
    
    NSLog(@"drafts: %@",draftsCodes);
    
    predicate = [NSPredicate predicateWithFormat:@"status == %@ AND NOT (code IN %@)",@"live",draftsCodes];
    
    //NSLog(@"predicate: %@",predicate);
    
    NSArray *filteredArray = [self.articles filteredArrayUsingPredicate:predicate];
    NSLog(@"without drafts %@",[filteredArray valueForKeyPath:@"name"]);
    //self.articles =  filteredArray.count > 0 ? [filteredArray mutableCopy] : nil;
    
    return [filteredArray mutableCopy];

}

#pragma mark - Utility methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView == self.phonesLanguageAlert){
        if (buttonIndex == 1) {
            [self setMainLanguageToPhonesLanguage];
        }
    }else if(alertView == self.draftsAlert){
        if(buttonIndex == 0){
            GTPackage *selectedPackage = [self.articles objectAtIndex:self.homeView.tableView.indexPathForSelectedRow.row];
            [self loadRendererWithPackage:selectedPackage];
        }else if(buttonIndex == 1){
            //[]; //
        }
    }else if(alertView == self.createDraftsAlert){
        if(buttonIndex > 0){
            GTPackage *selectedPackage = [[self packagesWithNoDrafts]objectAtIndex:buttonIndex-1];
            NSLog(@"%@ chosen",selectedPackage.name);
            [[GTDataImporter sharedImporter]createDraftsForLanguage:selectedPackage.language package:selectedPackage];
        }
    }
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
                if ([parallelPackage.code isEqualToString:package.code]) {
                    parallelConfigFile = parallelPackage.configFile;
                }
            }
        }
    }
    //[self.godtoolsViewController loadResourceWithConfigFilename:package.configFile];
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
    NSLog(@"view of page view controller");
    return _godtoolsViewController.view;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
