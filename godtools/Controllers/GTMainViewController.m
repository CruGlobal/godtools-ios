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
#import "FollowUpAPI.h"
#import "GTFollowUpSubscription.h"

NSString * const GTSplashErrorDomain                                            = @"org.cru.godtools.gtsplashviewcontroller.error.domain";
NSInteger const GTSplashErrorCodeInitialSetupFailed                             = 1;

@interface GTMainViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) GTInitialSetupTracker *setupTracker;
@property (nonatomic, strong) GTSplashScreenView *splashScreen;

- (void)persistLocalMetaData;
- (void)persistLocalEnglishPackage;

- (void)goToHome;

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
	
	//check to see if the database go reset due to a bad migration. If so rerun the first launch code.
	[[NSNotificationCenter defaultCenter] addObserverForName:CRUStorageNotificationRecoveryCompleted
													  object:nil
													   queue:nil
												  usingBlock:^(NSNotification * _Nonnull note) {
													  self.setupTracker.firstLaunch = YES;
												  }];
	

    [self leavePreviewMode];
    
    //check if first launch
    if(!self.setupTracker.firstLaunch) {
        [self sendCachedFollowupSubscriptions];
        
        __weak typeof(self) weakSelf = self;
        
        [[GTDataImporter sharedImporter] updateMenuInfo].finally(^{
            [weakSelf goToHome];
        });
        
        return;
    }
    
    [self.splashScreen showDownloadIndicatorWithLabel:NSLocalizedString(@"status_initial_setup", nil)];
    [self.setupTracker beganInitialSetup];
    
    //prepare initial content
    [self persistLocalEnglishPackage];
    [self persistLocalMetaData];
    
    __weak typeof(self) weakSelf = self;
    
    [[GTDataImporter sharedImporter] updateMenuInfo].then(^{
        GTLanguage *phonesLanguage = [[GTStorage sharedStorage] findClosestLanguageTo:[GTDefaults sharedDefaults].phonesLanguageCode];
        
        [[GTDataImporter sharedImporter] updateMenuInfo].then(^{
            if (phonesLanguage) {
                return [[GTDataImporter sharedImporter] downloadPromisedPackagesForLanguage:phonesLanguage];
            }
            return [PMKPromise promiseWithValue:@"finished"];
        }).then(^{
            [[GTDefaults sharedDefaults] setCurrentLanguageCode:(phonesLanguage ? phonesLanguage.code : @"en")];
            [weakSelf.setupTracker finishedDownloadingPhonesLanguage];
        }).catch(^{
            
        }).finally(^{
            [weakSelf initialSetupFinished];
        });
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[[GTGoogleAnalyticsTracker sharedInstance] setScreenName:@"SplashScreen"] sendScreenView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	
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

- (void)downloadPhonesLanguage:(GTLanguage *)phonesLanguage {
    __weak typeof(self) weakSelf = self;
    
    [self.splashScreen showDownloadIndicatorWithLabel:NSLocalizedString(@"status_downloading_resources", nil)];
    
    [GTDefaults sharedDefaults].isChoosingForMainLanguage = YES;
    
    [[GTDataImporter sharedImporter] downloadPromisedPackagesForLanguage:phonesLanguage].then(^{
        [weakSelf.setupTracker finishedDownloadingPhonesLanguage];
        [weakSelf initialSetupFinished];
    }).catch(^{
        [weakSelf initialSetupFailed];
    });
}


- (void)sendCachedFollowupSubscriptions {
    NSArray *subscriptions = [GTFollowUpSubscription MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"apiTransmissionSuccess == NIL || apiTransmissionSuccess == NO"]];
    
    [subscriptions enumerateObjectsUsingBlock:^(GTFollowUpSubscription * _Nonnull subscription, NSUInteger idx, BOOL * _Nonnull stop) {
        [[FollowUpAPI sharedAPI] sendNewSubscription:subscription
                                           onSuccess:^(AFHTTPRequestOperation *request, id obj) {
                                               [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
                                                   subscription.apiTransmissionSuccess = @YES;
                                                   subscription.apiTransmissionTimestamp = [NSDate date];
                                               } completion:nil];
                                           }
                                           onFailure:^(AFHTTPRequestOperation *request, NSError *error) {
                                               [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
                                                   subscription.apiTransmissionSuccess = @NO;
                                                   subscription.apiTransmissionTimestamp = [NSDate date];
                                               } completion:nil];
                                               
                                           }];
        
    }];
}

#pragma mark - UI methods

- (void)goToHome {
	[self performSegueWithIdentifier:@"splashToHomeViewSegue" sender:self];
}

- (void)initialSetupFinished {
	
	if([self.splashScreen.activityView isAnimating]){
		[self.splashScreen hideDownloadIndicator];
	}
	
	[self goToHome];
	self.setupTracker.firstLaunch = NO;
}

- (void)initialSetupFailed {
	
	if([self.splashScreen.activityView isAnimating]){
		[self.splashScreen hideDownloadIndicator];
	}
	
	NSError *error = [NSError errorWithDomain:GTSplashErrorDomain
										 code:GTSplashErrorCodeInitialSetupFailed
									 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"initial_setup_error_message", nil) }];
	
	[[GTErrorHandler sharedErrorHandler] displayError:error];
}

- (void)menuUpdateBegan:(NSNotification *)notification {
	
	[self.splashScreen showDownloadIndicatorWithLabel:NSLocalizedString(@"status_checking_for_updates", nil)];
}

- (void)menuUpdateFinished:(NSNotification *)notification {
	
	if([self.splashScreen.activityView isAnimating]){
		[self.splashScreen hideDownloadIndicator];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([[segue identifier] isEqualToString:@"splashToHomeViewSegue"]) {
		
		// Get reference to the destination view controller
		GTHomeViewController *home = [segue destinationViewController];
		home.shouldShowInstructions = self.setupTracker.firstLaunch;
	}
	
}

#pragma mark - Helper methods
- (void)leavePreviewMode {
    [[GTDefaults sharedDefaults] setIsInTranslatorMode:[NSNumber numberWithBool:NO]];
}

@end
