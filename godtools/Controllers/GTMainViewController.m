//
//  GTMainViewController.m
//  godtools
//
//  Created by Michael Harrison on 3/13/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTMainViewController.h"
#import "GTDataImporter.h"
#import "GTPackageExtractor.h"
#import "GTInitialSetupTracker.h"
#import "GTSplashScreenView.h"
#import "GTHomeViewController.h"

#import "GTGoogleAnalyticsTracker.h"

@interface GTMainViewController ()

@property (nonatomic, strong) GTInitialSetupTracker *setupTracker;
@property (nonatomic, strong) GTSplashScreenView *splashScreen;

- (void)persistLocalMetaData;
- (void)persistLocalEnglishPackage;
- (void)downloadPhonesLanguage;

- (void)updateMenu;
- (void)goToHome;

- (void)updateBegan:(NSNotification *)notification;
- (void)updateFinished:(NSNotification *)notification;
- (void)updateFailed:(NSNotification *)notification;

- (void)registerListenersForInitialSetup;
- (void)removeListenersForInitialSetup;

@end

@implementation GTMainViewController

- (void)viewDidLoad {
	
    [super viewDidLoad];

	self.setupTracker = [[GTInitialSetupTracker alloc] init];
	
	//UI config
    [self.navigationController setNavigationBarHidden:YES];
    self.splashScreen = (GTSplashScreenView*) [[[NSBundle mainBundle] loadNibNamed:@"GTSplashScreenView" owner:nil options:nil]objectAtIndex:0];
    self.splashScreen.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view = self.splashScreen;
    
    [self.splashScreen initDownloadIndicator];

    //check if first launch
    if(self.setupTracker.firstLaunch){
		
		[self registerListenersForInitialSetup];
		[self.setupTracker beganInitialSetup];
		
        //prepare initial content
        [self persistLocalEnglishPackage];
        [self persistLocalMetaData];
		
		//download phone's language
		[self downloadPhonesLanguage];
		
	} else {
		
		[self updateMenu];
		[self goToHome];
		
	}
	
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[[GTGoogleAnalyticsTracker sharedInstance] setScreenName:@"SplashScreen"] sendScreenView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	
}

#pragma mark - listener methods

- (void)registerListenersForInitialSetup {
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateBegan:)
												 name:GTInitialSetupTrackerNotificationDidBegin
											   object:self.setupTracker];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateFinished:)
												 name:GTInitialSetupTrackerNotificationDidFinish
											   object:self.setupTracker];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateFailed:)
												 name:GTInitialSetupTrackerNotificationDidFail
											   object:self.setupTracker];
	
}

- (void)removeListenersForInitialSetup {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:GTInitialSetupTrackerNotificationDidBegin
												  object:self.setupTracker];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:GTInitialSetupTrackerNotificationDidFinish
												  object:self.setupTracker];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:GTInitialSetupTrackerNotificationDidFail
												  object:self.setupTracker];
	
}

#pragma mark - API request methods

- (void)updateMenu {
	[[GTDataImporter sharedImporter] updateMenuInfo];
}

#pragma mark - UI methods

- (void)goToHome {
	[self performSegueWithIdentifier:@"splashToHomeViewSegue" sender:self];
	
}

- (void)updateBegan:(NSNotification *)notification {
	
    [self.splashScreen showDownloadIndicatorWithLabel:NSLocalizedString(@"GTHome_status_checkingForUpdates", nil)];
}


- (void)updateFinished:(NSNotification *)notification {
	
    if([self.splashScreen.activityView isAnimating]){
        [self.splashScreen hideDownloadIndicator];
    }
	
	[self removeListenersForInitialSetup];
	[self goToHome];
	self.setupTracker.firstLaunch = NO;
}

- (void)updateFailed:(NSNotification *)notification {
	
	if([self.splashScreen.activityView isAnimating]){
		[self.splashScreen hideDownloadIndicator];
	}
	
	[self removeListenersForInitialSetup];
	//show error
	
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([[segue identifier] isEqualToString:@"splashToHomeViewSegue"])
	{
		// Get reference to the destination view controller
		GTHomeViewController *home = [segue destinationViewController];
		home.shouldShowInstructions = self.setupTracker.firstLaunch;
	}
	
}

#pragma mark - First Launch methods

- (void)persistLocalMetaData {
	
	NSString* pathOfMeta = [[NSBundle mainBundle] pathForResource:@"meta" ofType:@"xml"];
	RXMLElement *metaXML = [RXMLElement elementFromXMLData:[NSData dataWithContentsOfFile:pathOfMeta]];
	
	if ([[GTDataImporter sharedImporter] importMenuInfoFromXMLElement:metaXML]) {
		
		[self.setupTracker finishedExtractingMetaData];
		
	} else {
		
		[self.setupTracker failedExtractingMetaData];
		
	}
	
}

- (void)persistLocalEnglishPackage {
	
	//retrieve or create the english language object.
	NSArray *englishArray = [[GTStorage sharedStorage] fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[@"en"] inBackground:YES];
	GTLanguage *english;
	if([englishArray count] == 0){
		english = [GTLanguage languageWithCode:@"en" inContext:[GTStorage sharedStorage].backgroundObjectContext];
		english.name = @"English";
	}else{
		english = [englishArray objectAtIndex:0];
		[english removePackages:english.packages];
	}
	
	NSURL* pathOfEnglishZip	= [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"en" ofType:@"zip"]];
	//unzips english package and moves it to documents folder
	RXMLElement *contents			= [[GTPackageExtractor sharedPackageExtractor] unzipResourcesAtTarget:pathOfEnglishZip forLanguage:english package:nil];
	
	//reads contents.xml and saves meta data to the database about all the packages found in the zip file.
	if ([[GTDataImporter sharedImporter] importPackageContentsFromElement:contents forLanguage:english]) {
		
		[self.setupTracker finishedExtractingEnglishPackage];
		
	} else {
		
		[self.setupTracker failedExtractingEnglishPackage];
		
	}
	
	[GTDefaults sharedDefaults].currentLanguageCode = english.code;
	
}

- (void)downloadPhonesLanguage {
#error incomplete implementation
	[self updateMenu];
	[[GTDefaults sharedDefaults] setIsChoosingForMainLanguage:[NSNumber numberWithBool: YES]];
	[[GTDataImporter sharedImporter] downloadPackagesForLanguage:[[[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults]phonesLanguageCode] inBackground:YES]objectAtIndex:0]];
}

#pragma mark - memory management methods

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
	
}

@end
