//
//  EveryStudentItemsController.m
//  God Tools
//
//  Created by Michael Harrison on 7/07/11.
//  Copyright 2011 CCCA. All rights reserved.
//

#import "EveryStudentItemsController.h"
#import "EveryStudentCell.h"

#import "GTGoogleAnalyticsTracker.h"

@interface EveryStudentItemsController ()

@property (nonatomic, weak)		IBOutlet UIImageView	*backgroundImage;

@end

@implementation EveryStudentItemsController

- (id)initWithArrayOfItems:(NSMutableArray *)items {
	
	self.arrayOfTableData	= items;
	
    return [self initWithNibName:@"EveryStudentItemsController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		
		UIColor		*backgroundColor	= [UIColor colorWithPatternImage:[UIImage imageNamed:@"HomeScreen_Background_Linen_Tile_Light"]];
		self.view.backgroundColor		= backgroundColor;
		
		self.articleView				= [[EveryStudentArticleView alloc] initWithNibName:@"EveryStudentArticleView" bundle:nil];
		
    }
	
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
		// Load resources for iOS 6.1 or earlier
	} else {
		// Load resources for iOS 7 or later
		self.itemsTable.frame = CGRectMake(CGRectGetMinX(self.itemsTable.frame),
											  CGRectGetMaxY(self.navigationController.navigationBar.frame),
											  CGRectGetWidth(self.itemsTable.frame),
											  CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame) - 20.0);
	}
	
	self.backgroundImage.frame		= self.view.frame;
	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark TableView Data Source and Delagate Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	EveryStudentCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	if (cell == nil) {
		cell = [[EveryStudentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
		UIView	*background	= [[UIView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width, cell.frame.size.height - 1)];
		background.tag		= 123;
		[cell insertSubview:background atIndex:0];
	}
	
    UIView *cellBackground	= [cell viewWithTag:123];
    
    //set the background on the inner part of the cell
    cellBackground.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.65];
    //allow the 14px separation
    cell.backgroundColor = [UIColor clearColor];	
	
	//add formatting
	cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor whiteColor];
	
	cell.textLabel.text	= [[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"name"];
	cell.imageView.image= [UIImage imageWithContentsOfFile:
										   [[NSBundle mainBundle] 
											pathForResource:@"EveryStudent_Icon_Article" 
											ofType:@"png"]];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [self.arrayOfTableData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    NSString *chosenArticleTitle = [[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    self.articleView.title		= chosenArticleTitle;
	self.articleView.article	= [[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"content"];
	self.articleView.language	= self.language;
	self.articleView.package	= self.package;
    
    [[[GTGoogleAnalyticsTracker sharedInstance] setScreenName:[self getEveryStudentTrackingTitle:chosenArticleTitle]] sendScreenView];
     
	[[self navigationController] pushViewController:self.articleView animated:YES];
}

-(NSString *) getEveryStudentTrackingTitle:(NSString *)articleTitle {
    NSString *lowercaseTitle = [articleTitle lowercaseString];
    NSString *lowercaseTitleWithDashes = [lowercaseTitle stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    return [@"everystudent-" stringByAppendingString: lowercaseTitleWithDashes];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
		// Load resources for iOS 6.1 or earlier
		return 22.0;
	} else {
		// Load resources for iOS 7 or later
		return 0.0;
	}
	
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
		// Load resources for iOS 6.1 or earlier
		return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PkgDwnldScrn_Bottom_Bar_NoShadow"]];
	} else {
		// Load resources for iOS 7 or later
		return nil;
	}
	
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
