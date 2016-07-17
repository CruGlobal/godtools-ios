//
//  EveryStudentController.m
//  God Tools
//
//  Created by Michael Harrison on 6/07/11.
//  Copyright 2011 CCCA. All rights reserved.
//

#import "EveryStudentController.h"
#import "EveryStudentItemsController.h"
#import "EveryStudentCell.h"
#import "EveryStudentSearchCell.h"
#import "EveryStudentArticleView.h"
#import "TBXML.h"

#import "GTGoogleAnalyticsTracker.h"

@interface EveryStudentController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak)		IBOutlet UISearchBar	*searchBar;
@property (nonatomic, weak)		IBOutlet UITableView	*categoryTable;
@property (nonatomic, weak)		IBOutlet UIImageView	*backgroundImage;

@property (nonatomic, strong)	EveryStudentArticleView	*articleView;

@property (nonatomic, strong)	NSMutableArray			*arrayOfAllCategories;
@property (nonatomic, strong)	NSMutableArray			*arrayOfAllItems;

@property (nonatomic, strong)	NSMutableArray			*arrayOfTableData;

@property (nonatomic)			BOOL					isSearching;
@property (nonatomic, strong)	NSString				*searchTerm;
@property (nonatomic, strong)	NSString				*searchTermAtLastPost;

- (void)loadEveryStudentXMLFromElement:(TBXMLElement *)root;
- (void)searchTableViewWithSearchTerm:(NSString *)searchTerm;
- (void)doneSearching:(id)sender;

@end

@implementation EveryStudentController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		
		UIColor		*backgroundColor	= [UIColor colorWithPatternImage:[UIImage imageNamed:@"GT4_HomeScreen_Background_"]];
		self.view.backgroundColor		= backgroundColor;
		
		[self setTitle:NSLocalizedString(@"everystudent_title", nil)];
		self.searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
        
        TBXML	*parser		= [[TBXML alloc] initWithXMLFile:@"EveryStudent.xml" error:nil];
        [self loadEveryStudentXMLFromElement:parser.rootXMLElement];
		
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		self.articleView	= [[EveryStudentArticleView alloc] initWithNibName:@"EveryStudentArticleView" bundle:nil];
		
		self.isSearching			= NO;
		self.searchTerm				= @"";
		self.searchTermAtLastPost	= @"";
    }
	
    return self;
}

//will fill self.arrayOfAllCategories with the following format
//[{category1, [{item1, item1Contents}, {item2, item2Contents}, ...]}, {category2, [{item1, item1Contents}, {item2, item2Contents}, ...]}, ...]
//and will fill self.arrayOfAllItems with the following format
//[{item1, item1Contents}, {item2, item2Contents}, {item3, item3Contents}, ...]
//where [] is an array and {} is a dictionary with a key and an object
- (void)loadEveryStudentXMLFromElement:(TBXMLElement *)root {
	
	self.arrayOfAllCategories			= [NSMutableArray array];
	self.arrayOfAllItems				= [NSMutableArray array];
	self.arrayOfTableData				= nil;
	
	TBXMLElement	*categoryElement	= [TBXML childElementNamed:@"category" parentElement:root];
	TBXMLElement	*itemElement		= nil;
	
	NSMutableDictionary	*itemObject		= nil;
	NSMutableDictionary	*categoryObject	= nil;
	NSMutableArray	*tempArrayOfItems	= nil;
	
	while (categoryElement != nil) {
		
		itemElement			= [TBXML childElementNamed:@"item" parentElement:categoryElement];
		
		categoryObject		= [[NSMutableDictionary alloc] init];
		tempArrayOfItems	= [[NSMutableArray alloc] init];
		
		while (itemElement != nil) {
			
			itemObject		= [[NSMutableDictionary alloc] init];
			[itemObject setObject:[[TBXML valueOfAttributeNamed:@"name" forElement:itemElement] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"] forKey:@"name"];
			[itemObject setObject:[[TBXML textForElement:itemElement] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"] forKey:@"content"];
			[tempArrayOfItems addObject:itemObject];
			[self.arrayOfAllItems addObject:itemObject];
			
			
			itemElement	= [TBXML nextSiblingNamed:@"item" searchFromElement:itemElement];
		}
		
		//add item array to category array as a category object
		[categoryObject setObject:[[TBXML valueOfAttributeNamed:@"name" forElement:categoryElement] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"] forKey:@"name"];
		[categoryObject setObject:tempArrayOfItems forKey:@"content"];
		[self.arrayOfAllCategories addObject:categoryObject];
		
		
		categoryElement	= [TBXML nextSiblingNamed:@"category" searchFromElement:categoryElement];
	}
	
	self.arrayOfTableData	= self.arrayOfAllCategories;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
		// Load resources for iOS 6.1 or earlier
	} else {
		// Load resources for iOS 7 or later
		self.categoryTable.frame = CGRectMake(CGRectGetMinX(self.categoryTable.frame),
											  CGRectGetMaxY(self.navigationController.navigationBar.frame),
											  CGRectGetWidth(self.categoryTable.frame),
											  CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame));
	}
	
	self.backgroundImage.frame		= self.view.frame;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.categoryTable setBackgroundView:nil];
    [self.categoryTable setBackgroundColor:[UIColor clearColor]];
	
    [[[GTGoogleAnalyticsTracker sharedInstance] setScreenName:@"EveryStudent"] sendScreenView];
}

- (void)dealloc {
	
	
	[self.arrayOfAllCategories removeAllObjects];
	
	[self.arrayOfAllItems removeAllObjects];
	
	[self.arrayOfTableData removeAllObjects];
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark TableView Data Source and Delagate Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier		= @"MyIdentifier";
	static NSString *MySearchIdentifier = @"MySearchIdentifier";
	
	EveryStudentCell		*cell		= [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	EveryStudentSearchCell	*searchCell	= nil;
	
	if (cell == nil) {
		
		cell = [[EveryStudentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
		UIView	*background	= [[UIView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width, cell.frame.size.height - 1)];
		background.tag		= 123;
		[cell insertSubview:background atIndex:0];
		
	}
	
	//add formatting
	cell.textLabel.font		= [UIFont systemFontOfSize:14];
    //color the text
    cell.textLabel.textColor = [UIColor whiteColor];
	UIView	*cellBackground	= [cell viewWithTag:123];
	
	//set the background on the inner part of the cell
    cellBackground.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.65];
    //allow the 14px separation
    cell.backgroundColor = [UIColor clearColor];
	
	if (self.isSearching) {
		
		@try {
			NSInteger charactersToDisplay	= 12;
			NSString *content				= [[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"content"];
			NSRange	substringRange			= [content rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
			
			if (substringRange.length > 0) {
				
				searchCell = (EveryStudentSearchCell *)[tableView dequeueReusableCellWithIdentifier:MySearchIdentifier];
				
				if (searchCell == nil) {
					searchCell = [[EveryStudentSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MySearchIdentifier];
					UIView	*searchBackground	= [[UIView alloc] initWithFrame:CGRectMake(searchCell.frame.origin.x, searchCell.frame.origin.y, tableView.frame.size.width, searchCell.frame.size.height - 1)];
					searchBackground.tag		= 123;
					[searchCell insertSubview:searchBackground atIndex:0];
				}
				
				UIView	*searchCellBackground	= [searchCell viewWithTag:123];
				
				//set alternating background color
				if ((indexPath.row % 2) == 0) {
					
					searchCellBackground.backgroundColor	= [UIColor colorWithRed:(244.0/255.0) green:(244.0/255.0) blue:(244.0/255.0) alpha:1.0];
					//cell.accessoryView.	= [UIColor colorWithRed:(244.0/255.0) green:(244.0/255.0) blue:(244.0/255.0) alpha:1.0];
					
				} else {
					
					//cell.contentView.backgroundColor	= [UIColor colorWithRed:(250.0/255.0) green:(250.0/255.0) blue:(250.0/255.0) alpha:1.0];
					searchCellBackground.backgroundColor	= [UIColor colorWithRed:(250.0/255.0) green:(250.0/255.0) blue:(250.0/255.0) alpha:1.0];
					
				}
				
				//NSLog(@"ssl: %d, length: %d", substringRange.location - charactersToDisplay, [content length]);
				substringRange.location = ((NSInteger)(substringRange.location - charactersToDisplay) < 0) ? 0 : substringRange.location - charactersToDisplay;
				substringRange.length	= ([content length] <= substringRange.location + substringRange.length + charactersToDisplay) ? substringRange.location + substringRange.length + charactersToDisplay : [content length] - substringRange.location - 1;
				
				//NSLog(@"%d, %d", substringRange.location, substringRange.length);
				searchCell.nameLabel.text			= [[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"name"];
				
				if (substringRange.location == 0) {
					searchCell.searchResultLabel.text	= [NSString stringWithFormat:@"%@", [content substringWithRange:substringRange]];
				} else {
					searchCell.searchResultLabel.text	= [NSString stringWithFormat:@"...%@", [content substringWithRange:substringRange]];
				}
				
				searchCell.imageView.image			= [UIImage imageWithContentsOfFile:
													   [[NSBundle mainBundle] 
														pathForResource:@"EveryStudent_Icon_Article" 
														ofType:@"png"]];
				
			} else {
				cell.textLabel.text			= [[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"name"];
				cell.imageView.image		= [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EveryStudent_Icon_Article" ofType:@"png"]];
			}
		}
		@catch (NSException *exception) {
			cell.textLabel.text		= [[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"name"];
			cell.imageView.image	= [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EveryStudentIcon" ofType:@"png"]];
		}
		
		cell.accessoryType	= UITableViewCellAccessoryNone;
	} else {
		cell.textLabel.text	= [[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"name"];
		cell.accessoryType	= UITableViewCellAccessoryDisclosureIndicator;
		cell.imageView.image= nil;
	}
	return (searchCell != nil) ? searchCell : cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58.;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [self.arrayOfTableData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, tableView.sectionHeaderHeight)];
    UIImage *image = [UIImage imageNamed:@"everyStudent"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y+25, header.frame.size.width, header.frame.size.height-50);
    [header addSubview:imageView];
    imageView.backgroundColor = [UIColor whiteColor];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (self.isSearching) {
		
		self.articleView.title		= [[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"name"];
		self.articleView.article	= [[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"content"];
		self.articleView.language	= self.language;
		self.articleView.package	= self.package;
		[[self navigationController] pushViewController:self.articleView animated:YES];
		
	} else {
		
		EveryStudentItemsController *itemsController	= [[EveryStudentItemsController alloc] initWithArrayOfItems:[[self.arrayOfTableData objectAtIndex:indexPath.row] objectForKey:@"content"]];
		itemsController.language						= self.language;
		itemsController.package							= self.package;
		[[self navigationController] pushViewController:itemsController animated:YES];
		
	}
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


#pragma mark - search bar delegate functions

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	if (!self.isSearching) {
		self.arrayOfTableData = self.arrayOfAllItems;
	}
	
	self.isSearching = YES;
	//self.categoryTable.scrollEnabled = NO;
	
	//Add the done button.
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self action:@selector(doneSearching:)];
	[self.categoryTable reloadData];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
	
	if (self.searchTerm.length > 0 && ![self.searchTerm isEqualToString:self.searchTermAtLastPost]) {
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:GTTrackerNotificationEverystudentDidSearch
//															object:self
//														  userInfo:@{GTTrackerNotificationUserInfoLanguageKey:	self.language,
//																	 GTTrackerNotificationUserInfoPackageKey:	self.package,
//																	 GTTrackerNotificationUserInfoVersionKey:	@1,
//																	 GTTrackerNotificationEverystudentDidSearchUserInfoSearchTerm: self.searchTerm }];
//		
		self.searchTermAtLastPost	= self.searchTerm;
	}
	
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	
	if ([searchText length] > 0) {
		self.isSearching = YES;
		self.categoryTable.scrollEnabled = YES;
		self.searchTerm	= searchText;
		[self searchTableViewWithSearchTerm:self.searchTerm];
	} else {
		self.arrayOfTableData = self.arrayOfAllItems;
	}
	
	
	[self.categoryTable reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	self.searchTerm	= theSearchBar.text;
	[self searchTableViewWithSearchTerm:self.searchTerm];
	[theSearchBar resignFirstResponder];
	
}

- (void)searchTableViewWithSearchTerm:(NSString *)searchTerm {
	
	NSString		*searchText		= searchTerm;
	NSMutableArray	*searchArray	= [NSMutableArray array];
	
	for (NSDictionary *dictionary in self.arrayOfAllItems)
	{
		NSRange titleResultsRange = [[dictionary objectForKey:@"content"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0) {
			[searchArray addObject:dictionary];
		}
	}
	
	self.arrayOfTableData = searchArray;
}

- (void)doneSearching:(id)sender {
	self.searchBar.text = @"";
	[self.searchBar resignFirstResponder];
	
	self.isSearching = NO;
	self.navigationItem.rightBarButtonItem = nil;
	self.categoryTable.scrollEnabled = YES;
	
	self.arrayOfTableData = self.arrayOfAllCategories;
	[self.categoryTable reloadData];
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
