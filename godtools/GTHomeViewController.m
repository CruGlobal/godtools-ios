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
#import "GTLanguage+Helper.h"
#import "GTPackage+Helper.h"
#import "GTStorage.h"

@interface GTHomeViewController ()
    @property (strong,nonatomic) NSString *languageCode;
    @property (nonatomic, strong) GTViewController *godtoolsViewController;
@end

@implementation GTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    [self.tableView setBounces:NO];
    
    self.articles = [[NSMutableArray alloc]init];
    [self setData];
    [self.tableView reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)setData{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.languageCode = [defaults stringForKey:@"mainLanguage"];
    NSArray *languages = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[self.languageCode] inBackground:NO];
    
    GTLanguage* mainLanguage = (GTLanguage*)[languages objectAtIndex:0];
    
    NSLog(@"mainlanguage: %@",mainLanguage);
    
    self.articles = [mainLanguage.packages allObjects];
}

#pragma  mark - GodToolsViewController getter
- (GTViewController *)godtoolsViewController {
    
    if (!_godtoolsViewController) {
        
        GTPackage *package = [self.articles objectAtIndex:0];
        
        //NSString *configFile	= [NSString stringWithFormat:@"/%@",package.configFile];
        
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GTHomeViewCell *cell = (GTHomeViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GTHomeViewCell"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GTHomeViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    GTPackage *package = [self.articles objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = package.name;
    
    NSString *imageFilePath = [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:package.icon];
    
    cell.icon.image = [UIImage imageWithContentsOfFile: imageFilePath];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GTPackage *package = [self.articles objectAtIndex:indexPath.row];
    
    //NSString *configFile	= [NSString stringWithFormat:@"%@/%@",self.languageCode,package.configFile];
    
    [self.godtoolsViewController loadResourceWithConfigFilename:package.configFile];
    
    [self.navigationController pushViewController:self.godtoolsViewController animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
