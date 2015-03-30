//
//  EveryStudentArticleView.m
//  God Tools
//
//  Created by devteam on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EveryStudentArticleView.h"

#import "GTTrackerNotifications.h"

@interface EveryStudentArticleView ()

@property (nonatomic, weak) IBOutlet UITextView *content;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;

@end

@implementation EveryStudentArticleView
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
		// Load resources for iOS 6.1 or earlier
		self.content.frame = CGRectMake(CGRectGetMinX(self.content.frame),
										CGRectGetMaxY(self.navigationController.navigationBar.frame),
										CGRectGetWidth(self.content.frame),
										CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame));
		
	} else {
		// Load resources for iOS 7 or later
		self.content.frame = CGRectMake(CGRectGetMinX(self.content.frame),
										CGRectGetMaxY(self.navigationController.navigationBar.frame),
										CGRectGetWidth(self.content.frame),
										CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame) - 20.0);
		
	}
	
	self.content.contentOffset	= CGPointMake(0.0f, 0.0f);
	self.content.text			= self.article;
	
	self.backgroundImage.frame		= self.view.frame;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:GTTrackerNotificationEverystudentDidOpenArticle
														object:self
													  userInfo:@{GTTrackerNotificationUserInfoLanguageKey:	self.language,
																 GTTrackerNotificationUserInfoPackageKey:	self.package,
																 GTTrackerNotificationUserInfoVersionKey:	@1,
																 GTTrackerNotificationEverystudentDidOpenArticleUserInfoArticleName: self.title}];
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	self.content			= nil;
	self.backgroundImage	= nil;
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
