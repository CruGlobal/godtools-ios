//
//  GTLanguagesViewController.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTLanguagesViewController.h"
#import "GTLanguageViewCell.h"
#import "GTStorage.h"
#import "GTLanguage+Helper.h"
#import "GTPackage+Helper.h"
#import "GTDataImporter.h"
#import "GTDefaults.h"

@interface GTLanguagesViewController ()
    @property (strong,nonatomic) NSMutableArray *languages;
    @property (strong, nonatomic) UIAlertView *buttonLessAlert;
    @property AFNetworkReachabilityManager *afReachability;
@end

@implementation GTLanguagesViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setData];
    
    [self setTitle : @"Language"];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setData)
                                                 name: GTDataImporterNotificationAuthTokenUpdateStarted
                                               object:nil];*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToHome)
                                                 name: GTDataImporterNotificationLanguageDownloadProgressMade
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
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    self.afReachability = [AFNetworkReachabilityManager managerForDomain:@"www.google.com"];
    [self.afReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status < AFNetworkReachabilityStatusReachableViaWWAN) {
            NSLog(@"No internet connection!");
        }
    }];
    
    [self.afReachability startMonitoring];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.afReachability stopMonitoring];
}

- (void)goToHome{
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
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
    
    // NSMutableArray *filteredArray = [[NSMutableArray alloc]init];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.languages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GTLanguageViewCell *cell = (GTLanguageViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GTLanguageViewCell"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GTLanguageViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    GTLanguage *language = [self.languages objectAtIndex:indexPath.row];
    cell.languageName.text = language.name;
    BOOL textShouldBeHighlighted = ([[GTDefaults sharedDefaults] isChoosingForMainLanguage] == [NSNumber numberWithBool:YES] && [language.code isEqual:[[GTDefaults sharedDefaults]currentLanguageCode]])
        || ([[GTDefaults sharedDefaults] isChoosingForMainLanguage] == [NSNumber numberWithBool:NO]
            && [language.code isEqual:[[GTDefaults sharedDefaults]currentParallelLanguageCode]]);
    
    if(textShouldBeHighlighted){
           cell.languageName.textColor = [UIColor blueColor];
    }
    
    if(language.downloaded){
        [cell.downloadIcon setHidden:YES];
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    GTLanguage *chosen = (GTLanguage*)[self.languages objectAtIndex:indexPath.row];
    
    if(![chosen downloaded]){
        
        if(self.afReachability.reachable){

            [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDownloadProgressMade
                                                                object:self
                                                              userInfo:nil];
        
            [[GTDataImporter sharedImporter]downloadPackagesForLanguage:[self.languages objectAtIndex:indexPath.row]];
        }else{
            self.buttonLessAlert.message = NSLocalizedString(@"You need to be online to proceed", nil);
            [self.buttonLessAlert show];
            [self performSelector:@selector(dismissAlertView:) withObject:self.buttonLessAlert afterDelay:2.0];

         }
        
    }else{
        if([[GTDefaults sharedDefaults] isChoosingForMainLanguage] == [NSNumber numberWithBool:YES]){
            [[GTDefaults sharedDefaults]setCurrentLanguageCode:chosen.code];
        }else{
            NSLog(@"set as parallel: %@",chosen.code);
            [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:chosen.code];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}


@end
