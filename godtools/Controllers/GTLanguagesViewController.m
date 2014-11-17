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
#import "GTDataImporter.h"

@interface GTLanguagesViewController ()
    @property (strong,nonatomic) NSArray *languages;
@end

@implementation GTLanguagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[GTDataImporter sharedImporter]updateMenuInfo];
    
    self.languages = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] inBackground:NO];
    
    NSArray *sortedArray;
    sortedArray = [self.languages sortedArrayUsingSelector:@selector(compare:)];
    
    self.languages = sortedArray;
    
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
    
    if([language.code isEqual:[[NSUserDefaults standardUserDefaults]stringForKey:@"mainLanguage"]]){
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDownloadProgressMade
                                                            object:self
                                                          userInfo:nil];
        [[GTDataImporter sharedImporter]downloadPackagesForLanguage:[self.languages objectAtIndex:indexPath.row]];
        
    }else{
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[chosen code] forKey:@"mainLanguage"];
        
    }
    
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}


@end
