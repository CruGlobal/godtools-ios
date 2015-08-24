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

#import "GTGoogleAnalyticsTracker.h"

@interface GTMainViewController ()
@property (nonatomic, strong) GTInitialSetupTracker *setupTracker;
    @property (nonatomic, strong) GTSplashScreenView *splashScreen;
@end

@implementation GTMainViewController

- (void)viewDidLoad {
	
    [super viewDidLoad];

	self.setupTracker = [[GTInitialSetupTracker alloc] init];
    [self.navigationController setNavigationBarHidden:YES];
    
    self.splashScreen = (GTSplashScreenView*) [[[NSBundle mainBundle] loadNibNamed:@"GTSplashScreenView" owner:nil options:nil]objectAtIndex:0];
    self.splashScreen.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view = self.splashScreen;

    NSLog(@"SPLASH IS   %@", [self.splashScreen class]);
    
    [self.splashScreen initDownloadIndicator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFinished:)
                                                 name: GTDataImporterNotificationMenuUpdateFinished
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoadingIndicator:)
                                                 name: GTDataImporterNotificationMenuUpdateStarted
                                               object:nil];

    //check if first launch
    if(self.setupTracker.firstLaunch){
        //prepare initial content
        [self extractBundle];
        [self extractMetaData];
    }
    
    if(![[GTDefaults sharedDefaults] genericApiToken]) {
        [self requestGenericAuthToken];
    } else {
        [self updateMenu];
        [self goToHome];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[[GTGoogleAnalyticsTracker sharedInstance] setScreenName:@"SplashScreen"] sendScreenView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GTDataImporterNotificationMenuUpdateFinished
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GTDataImporterNotificationMenuUpdateStarted                                              object:nil];
}

-(void)goToHome{
    NSLog(@"go to home");
    [self performSelector:@selector(performSegueToHome) withObject:nil afterDelay:1.0];

}

-(void)performSegueToHome{
     [self performSegueWithIdentifier:@"splashToHomeViewSegue" sender:self];
}

-(void) requestGenericAuthToken {
    [[GTAPI sharedAPI] getAuthTokenForDeviceID:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSString *authToken) {
                                           [[GTDefaults sharedDefaults] setGenericApiToken:authToken];
                                           [[GTAPI sharedAPI] setAuthToken:authToken];
                                           [self updateFromApi];
                                           [self goToHome];
                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           NSLog(@"generic auth failed!!");
                                           [self goToHome];
                                       }];
}

-(void)updateFromApi {
    [self updateMenu];
    [[GTDefaults sharedDefaults] setIsChoosingForMainLanguage:[NSNumber numberWithBool: YES]];
    [[GTDataImporter sharedImporter] downloadPackagesForLanguage:[[[GTStorage sharedStorage]fetchModel:[GTLanguage class] usingKey:@"code" forValue:[[GTDefaults sharedDefaults]phonesLanguageCode] inBackground:YES]objectAtIndex:0]];
}

-(void)updateMenu{
	[[GTDataImporter sharedImporter] updateMenuInfo];
}

-(void)showLoadingIndicator:(NSNotification *) notification{
    [self.splashScreen showDownloadIndicatorWithLabel:NSLocalizedString(@"GTHome_status_checkingForUpdates", nil)];
}


-(void)updateFinished:(NSNotification *) notification{
    NSLog(@"notification main: %@",notification.name);
    if([self.splashScreen.activityView isAnimating]){
        [self.splashScreen hideDownloadIndicator];
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
	[[GTDataImporter sharedImporter] importPackageContentsFromElement:contents forLanguage:english];
	
	[GTDefaults sharedDefaults].currentLanguageCode = english.code;
	
}

- (void)extractMetaData{

    NSString* pathOfMeta = [[NSBundle mainBundle] pathForResource:@"meta" ofType:@"xml"];
    RXMLElement *metaXML = [RXMLElement elementFromXMLData:[NSData dataWithContentsOfFile:pathOfMeta]];
    
    [[GTDataImporter sharedImporter] importMenuInfoFromXMLElement:metaXML];

}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
	
}

@end
