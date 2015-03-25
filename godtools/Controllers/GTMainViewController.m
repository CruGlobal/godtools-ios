//
//  GTMainViewController.m
//  godtools
//
//  Created by Michael Harrison on 3/13/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTMainViewController.h"
#import "GTDataImporter.h"
#import "RXMLElement.h"
#import "SSZipArchive.h"
#import "GTLanguage+Helper.h"
#import "GTPackage+Helper.h"
#import "TBXML.h"
#import "GTDefaults.h"
#import "GTBaseView.h"
#import "GTSplashScreenView.h"

@interface GTMainViewController ()
    @property (nonatomic, strong) NSArray *resources;
    @property (nonatomic, strong) GTSplashScreenView *splashScreen;
    @property AFNetworkReachabilityManager *afReachability;
@end

@implementation GTMainViewController

- (void)viewDidLoad {
	
    [super viewDidLoad];

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
    
   /* [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authorizeTranslatorAlert:)
                                                 name: GTDataImporterNotificationAuthTokenUpdateStarted
                                               object:nil];*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMenu)
                                                 name: GTDataImporterNotificationAuthTokenUpdateSuccessful
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMenu)
                                                 name: GTDataImporterNotificationAuthTokenUpdateFail
                                               object:nil];
    
    self.afReachability = [AFNetworkReachabilityManager managerForDomain:@"www.google.com"];
    [self.afReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status < AFNetworkReachabilityStatusReachableViaWWAN) {
            NSLog(@"No internet connection!");
        }
    }];
    
    [self.afReachability startMonitoring];

    //check if first launch
    if([[GTDefaults sharedDefaults]isFirstLaunch] == [NSNumber numberWithBool:YES]){
        //prepare initial content
        [self extractBundle];
        [self extractMetaData];
        [[GTDefaults sharedDefaults]setIsFirstLaunch:[NSNumber numberWithBool:NO]];
    }
    
    if([[GTDefaults sharedDefaults]isInTranslatorMode] == [NSNumber numberWithBool:YES]){// && self.afReachability.reachable){
        [[GTDataImporter sharedImporter] authorizeTranslator];
    }//else{
    //    [[GTDefaults sharedDefaults]setIsInTranslatorMode:[NSNumber numberWithBool:NO]];
    //}
    else{
        [self updateMenu];
    }
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GTDataImporterNotificationMenuUpdateFinished
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GTDataImporterNotificationMenuUpdateStarted
                                                  object:nil];
}

-(void)goToHome{
    NSLog(@"go to home");
    [self performSelector:@selector(performSegueToHome) withObject:nil afterDelay:1.0];

}

-(void)performSegueToHome{
     [self performSegueWithIdentifier:@"splashToHomeViewSegue" sender:self];
}

-(void)updateMenu{
    if(self.afReachability.reachable){
        [[GTDataImporter sharedImporter] updateMenuInfo];
    }else{
        NSLog(@"NOT REACHABLE");
        [self goToHome];
    }
}

-(void)showLoadingIndicator:(NSNotification *) notification{
    [self.splashScreen showDownloadIndicatorWithLabel:@"Checking for Updates"];
}


-(void)updateFinished:(NSNotification *) notification{
    NSLog(@"notification main: %@",notification.name);
    if([self.splashScreen.activityView isAnimating]){
        [self.splashScreen hideDownloadIndicator];
    }
    [self goToHome];
    
}

-(void)extractBundle{
    //WILL ONLY BE TRIGERRED AT FRESH INSTALL
    [self.splashScreen showDownloadIndicatorWithLabel:[NSString stringWithFormat:(NSLocalizedString(@"GTHome_status_updatingResources", nil)),@"English"]];
   
    NSError *error;
    
    NSString *temporaryFolderName	= [[NSUUID UUID] UUIDString];
    NSString* temporaryDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:temporaryFolderName];

    
    if (![[NSFileManager defaultManager] fileExistsAtPath:temporaryDirectory]){    //Does directory already exist?
        if (![[NSFileManager defaultManager] createDirectoryAtPath:temporaryDirectory withIntermediateDirectories:NO attributes:nil error:&error]){
            NSLog(@"Create directory error: %@", error);
        }
    }
    
    NSString* pathOfEnglishBundle = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"zip"];
    
    //unzip to temporary directory
    if(![SSZipArchive unzipFileAtPath:pathOfEnglishBundle
                        toDestination:temporaryDirectory
                            overwrite:NO
                             password:nil
                                error:&error
                             delegate:nil]) {
        
        //[self displayDownloadPackagesUnzippingError:error];
        NSLog(@"error unzipping file");
        #warning error handling
    }
    if(!error){
        RXMLElement *rootXML = [RXMLElement elementFromXMLData:[NSData dataWithContentsOfFile:[temporaryDirectory stringByAppendingPathComponent:@"contents.xml"]]];

        //Update database with config filenames.
        NSArray *englishArray = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[@"en"] inBackground:YES];
        GTLanguage *english;
        if([englishArray count]==0){
            english = [GTLanguage languageWithCode:@"en" inContext:[GTStorage sharedStorage].backgroundObjectContext];
            english.name = @"English";
        }else{
            english = [englishArray objectAtIndex:0];
            [english removePackages:english.packages];
        }
        
        [rootXML iterate:@"resource" usingBlock: ^(RXMLElement *resource) {
           
            NSString *existingIdentifier = [GTPackage identifierWithPackageCode:[resource attribute:@"package"] languageCode:english.code];
            
            NSArray *packageArray = [[GTStorage sharedStorage]fetchArrayOfModels:[GTPackage class] usingKey:@"identifier" forValues:@[existingIdentifier] inBackground:YES];
            
            GTPackage *package;
            
            if([packageArray count]==0){
                NSLog(@"create new package");
                package = [GTPackage packageWithCode:[resource attribute:@"package"] language:english inContext:[GTStorage sharedStorage].backgroundObjectContext];
            }else{
                NSLog(@"get old package");
                package = [packageArray objectAtIndex:0];
            }
            
            package.name = [resource attribute:@"name"];
            package.configFile = [resource attribute:@"config"];
            package.icon = [resource attribute:@"icon"];
            package.status = [resource attribute:@"status"];
            package.localVersion = [NSNumber numberWithFloat:[[resource attribute:@"version"] floatValue] ];
            package.latestVersion = [NSNumber numberWithFloat:[[resource attribute:@"version"] floatValue] ];

            [english addPackagesObject:package];
            
        }];
        
        english.downloaded = [NSNumber numberWithBool: YES];
        if (![[GTStorage sharedStorage].backgroundObjectContext save:&error]) {
            NSLog(@"error saving");
        }
        
        //move to Packages folder
        NSString *destinationPath = [GTFileLoader pathOfPackagesDirectory];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]){
            if (![[NSFileManager defaultManager] createDirectoryAtPath:destinationPath withIntermediateDirectories:NO  attributes:nil error:&error]){
                NSLog(@"Create directory error: %@", error);
            }
        }
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        for (NSString *file in [fm contentsOfDirectoryAtPath:temporaryDirectory error:&error]) {
            if(![file  isEqual: @"contents.xml"]){
                NSString *filepath = [NSString stringWithFormat:@"%@/%@",temporaryDirectory,file];
                BOOL success = [fm copyItemAtPath:filepath toPath:[NSString stringWithFormat:@"%@/%@",destinationPath,file] error:&error] ;
                if (!success || error) {
                    NSLog(@"Error: %@",[error localizedDescription]);
                }else{
                    [fm removeItemAtPath:filepath error:&error];
                }
            }
        }
        
        if(!error){
            [fm removeItemAtPath:temporaryDirectory error:&error];
        }
            
        [[GTDefaults sharedDefaults]setCurrentLanguageCode:english.code];

    }
}

-(void)extractMetaData{

    NSString* pathOfMeta = [[NSBundle mainBundle] pathForResource:@"meta" ofType:@"xml"];
    RXMLElement *metaXML = [RXMLElement elementFromXMLData:[NSData dataWithContentsOfFile:pathOfMeta]];
    
    [[GTDataImporter sharedImporter]persistMenuInfoFromXMLElement:metaXML];

}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
	
}

@end
