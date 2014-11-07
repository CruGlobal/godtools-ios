//
//  GTHomeViewController.m
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTHomeViewController.h"
#import "GTHomeViewCell.h"
#import "GTLanguage+Helper.h"
#import "GTPackage+Helper.h"
#import "GTStorage.h"

@interface GTHomeViewController ()
    @property (nonatomic, strong, readonly)	GTStorage		*storage;
@end

@implementation GTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    //NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    //NSEntityDescription *entity = [NSEntityDescription entityForName:@"Language"  inManagedObjectContext: [GTStorage sharedStorage].backgroundObjectContext];
    //[fetch setEntity:entity];
    //[fetch setPredicate:[NSPredicate predicateWithFormat:@"(name = %@)",[defaults objectForKey:@"mainLanguage"]]];
    NSError * error = nil;
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Language" inManagedObjectContext:[GTStorage sharedStorage].mainObjectContext];
    
    NSLog(@"ENTITY: %@",entity);
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",[defaults stringForKey:@"mainLanguage"]]];
    GTLanguage* mainLanguage = (GTLanguage*)[[  self.storage.backgroundObjectContext executeFetchRequest:fetchRequest error:&error]objectAtIndex:0];
    
    //GTLanguage* mainLanguage = [[[GTStorage sharedStorage].backgroundObjectContext executeFetchRequest:fetch error:&error]objectAtIndex:0];
    
    self.articles = [mainLanguage.packages allObjects];
    
    NSLog(@"mainLanguage: %@, articles: %@",mainLanguage,self.articles);
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
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130.0f;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
