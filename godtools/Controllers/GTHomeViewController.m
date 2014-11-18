//
//  GTHomeViewController.m
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTHomeViewController.h"
#import <GTViewController/GTViewController.h>
#import "GTHomeViewCell.h"
#import "GTHomeView.h"
#import "GTLanguage+Helper.h"
#import "GTPackage+Helper.h"
#import "GTStorage.h"
#import "GTDataImporter.h"
#import "GTDefaults.h"


@interface GTHomeViewController ()

@property (strong,nonatomic) NSString *languageCode;
@property (strong, nonatomic) GTViewController *godtoolsViewController;
@property (strong, nonatomic) UIActivityIndicatorView *downloadIndicatorView;
@property (strong, nonatomic) GTHomeView *homeView;

@end

@implementation GTHomeViewController

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
    [self.homeView.tableView.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.homeView.tableView.layer setBorderWidth:2.0f];
    [self.homeView.tableView.layer setCornerRadius:8.0f];

    [self.homeView initDownloadIndicator];
    
    self.articles = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFinished:)
                                                 name: GTDataImporterNotificationLanguageDownloadFinished
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDownloadIndicator:)
                                                 name: GTDataImporterNotificationLanguageDownloadProgressMade
                                               object:nil];
    
}

-(void)downloadFinished:(NSNotification *) notification{
    
    if([self.homeView.activityView isAnimating]){
        [self.homeView hideDownloadIndicator];
    }

    [self setData];
    [self.homeView.tableView reloadData];
}

-(void)showDownloadIndicator:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
    
    NSLog(@" downloading %@",[userInfo objectForKey:GTDataImporterNotificationLanguageDownloadPercentageKey]);

    if(![self.homeView.activityView isAnimating]){
        [self.homeView showDownloadIndicator];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    //if(! [self.languageCode isEqual:[[NSUserDefaults standardUserDefaults] stringForKey:@"current_language_code"]]){
    if(! [self.languageCode isEqual:[[GTDefaults sharedDefaults] currentLanguageCode]]){
        [self setData];
        [self.homeView.tableView reloadData];
    }
}

-(void)settingsButtonPressed{
    [self performSegueWithIdentifier:@"homeToSettingsViewSegue" sender:self];
}

-(void)setData{
    
    self.languageCode = [[GTDefaults sharedDefaults]currentLanguageCode];
    NSArray *languages = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[self.languageCode] inBackground:NO];
    
    GTLanguage* mainLanguage = (GTLanguage*)[languages objectAtIndex:0];
    
    self.articles = [mainLanguage.packages allObjects];
    
    NSLog(@"articles: %@",self.articles);
}

#pragma  mark - GodToolsViewController getter
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
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
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
        [self.homeView.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        GTPackage *package = [self.articles objectAtIndex:indexPath.row];
        
        [self.godtoolsViewController loadResourceWithConfigFilename:package.configFile];
        
        [self.navigationController pushViewController:self.godtoolsViewController animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
