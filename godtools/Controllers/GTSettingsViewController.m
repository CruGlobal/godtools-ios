//
//  GTSettingsViewController.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTSettingsViewController.h"
#import "GTSettingsViewCell.h"
#import "GTLanguage+Helper.h"
#import "GTStorage.h"

@interface GTSettingsViewController ()
    @property (strong, nonatomic) GTLanguage *mainLanguage;
    @property (strong, nonatomic) GTLanguage *parallelLanguage;
@end

@implementation GTSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setBounces:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.tableView reloadData];
}

-(GTLanguage *)mainLanguage{
    NSString *mainLanguageCode = [[NSUserDefaults standardUserDefaults]stringForKey:@"mainLanguage"];
    NSArray *languages = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[mainLanguageCode] inBackground:NO];
    
    return (GTLanguage*)[languages objectAtIndex:0];
}

-(GTLanguage *)parallelLanguage{
    NSString *code = [[NSUserDefaults standardUserDefaults]stringForKey:@"parallelLanguage"];
    if(code != nil){
        NSArray *languages = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[code] inBackground:NO];
        return (GTLanguage*)[languages objectAtIndex:0];
    }else{
        return nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GTSettingsViewCell *cell = (GTSettingsViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GTSettingsViewCell"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GTSettingsViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.label.text = @"Main language";
            break;
        case 1:
            cell.label.text = self.mainLanguage.name;
            [cell addSeparator];
            break;
        case 2:
            cell.label.text = @"Parallel language";
            break;
        case 3:
            if(self.parallelLanguage){
                cell.label.text = self.parallelLanguage.name;
            }else{
                cell.label.text = self.mainLanguage.name;
            }

            [cell addSeparator];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 1:
            [self performSegueWithIdentifier:@"settingsToLanguageViewSegue" sender:self];
            break;
        case 2:
            //cell.label.text = @"Parallel language";
            break;
        case 3:
            //cell.label.text = self.mainLanguage.name;
            //[cell addSeparator];
            break;
        default:
            break;
    }
    
}



@end
