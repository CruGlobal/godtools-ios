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
#import "GTBaseView.h"

@interface GTMainViewController ()
    @property (nonatomic, strong) GTViewController *godtoolsViewController;
    @property (nonatomic, strong) GTBaseView *baseView;
    @property (nonatomic, strong) NSArray *resources;
@end

@implementation GTMainViewController

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
#warning check if there is internet connection

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.baseView = [[GTBaseView alloc]initWithFrame:self.view.frame];
    [self.baseView initDownloadIndicator];
    [self.view addSubview:self.baseView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFinished:)
                                                 name: GTDataImporterNotificationUpdatedFinished
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateStarted:)
                                                 name: GTDataImporterNotificationUpdatedStarted
                                               object:nil];
    
    //check if first launch
    if([defaults objectForKey:@"isDoneWithFirstLaunch"]==nil){
        //prepare initial content
        [self extractMetaData];
        [self extractBundle];
        [defaults setBool:YES forKey:@"isDoneWithFirstLaunch"];
    }
    
    [[GTDataImporter sharedImporter] updateMenuInfo];
    
}

-(void)updateStarted:(NSNotification *) notification{
    NSLog(@"updating...");
    self.baseView.loadingLabel.text = @"Updating Resources...";
    if(![self.baseView.activityView isAnimating]){
        [self.baseView showDownloadIndicator];
    }
}


-(void)updateFinished:(NSNotification *) notification{
    if([self.baseView.activityView isAnimating]){
        [self.baseView hideDownloadIndicator];
    }
   [self performSegueWithIdentifier:@"splashToHomeViewSegue" sender:self];
    
}

-(void)extractBundle{

   // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
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
    
    RXMLElement *rootXML = [RXMLElement elementFromXMLData:[NSData dataWithContentsOfFile:[temporaryDirectory stringByAppendingPathComponent:@"contents.xml"]]];

    //Update database with config filenames.
    NSArray *englishArray = [[GTStorage sharedStorage]fetchArrayOfModels:[GTLanguage class] usingKey:@"code" forValues:@[@"en"] inBackground:NO];
    GTLanguage *english;
    if([englishArray count]==0){
        english = [GTLanguage languageWithCode:@"en" inContext:[GTStorage sharedStorage].mainObjectContext];
        english.name = @"English";
    }else{
        english = [englishArray objectAtIndex:0];
        [english removePackages:english.packages];
    }
    
    [rootXML iterate:@"resource" usingBlock: ^(RXMLElement *resource) {
       
        NSString *existingIdentifier = [GTPackage identifierWithPackageCode:[resource attribute:@"package"] languageCode:english.code];
        
        NSArray *packageArray = [[GTStorage sharedStorage]fetchArrayOfModels:[GTPackage class] usingKey:@"identifier" forValues:@[existingIdentifier] inBackground:NO];
        
        GTPackage *package;
        
        if([packageArray count]==0){
            package = [GTPackage packageWithCode:[resource attribute:@"package"] language:english inContext:[GTStorage sharedStorage].mainObjectContext];
        }else{
            package = [packageArray objectAtIndex:0];
        }
        
        package.name = [resource attribute:@"name"];
        package.configFile = [resource attribute:@"config"];
        package.icon = [resource attribute:@"icon"];
        package.status = [resource attribute:@"status"];
        package.localVersion = [NSNumber numberWithInt:[[resource attribute:@"version"] integerValue] ];
        package.latestVersion = [NSNumber numberWithInt:[[resource attribute:@"version"] integerValue] ];

        [english addPackagesObject:package];
        
    }];
    
    english.downloaded = [NSNumber numberWithBool: YES];
    if (![[GTStorage sharedStorage].mainObjectContext save:&error]) {
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
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:english.code forKey:@"current_language_code"];
    
    [[GTDefaults sharedDefaults]setCurrentLanguageCode:english.code];
    
}

-(void)extractMetaData{
    NSError *error;
    NSString* pathOfMeta = [[NSBundle mainBundle] pathForResource:@"meta" ofType:@"xml"];
    RXMLElement *metaXML = [RXMLElement elementFromXMLData:[NSData dataWithContentsOfFile:pathOfMeta]];
    
    [metaXML iterate:@"language" usingBlock: ^(RXMLElement *languageElement) {
        
        __block GTLanguage *language = [GTLanguage languageWithCode:[languageElement attribute:@"code"] inContext:[GTStorage sharedStorage].mainObjectContext];
        
        language.name = [languageElement attribute:@"name"];
        
        [languageElement iterate:@"packages.package" usingBlock: ^(RXMLElement *packageElement) {
            
            GTPackage* package	= [GTPackage packageWithCode:[packageElement attribute:@"code"] language:language inContext:[GTStorage sharedStorage].mainObjectContext];
            package.name = [packageElement attribute:@"name"];
            package.configFile = [packageElement attribute:@"config"];
            package.icon = [packageElement attribute:@"icon"];
            package.status = [packageElement attribute:@"status"];
            package.localVersion = [NSNumber numberWithInt:[[packageElement attribute:@"version"] integerValue] ];
            package.latestVersion = [NSNumber numberWithInt:[[packageElement attribute:@"version"] integerValue] ];
            
            [language addPackagesObject:package];
        }];
    }];

    if (![[GTStorage sharedStorage].mainObjectContext save:&error]) {
        [[GTStorage sharedStorage]errorHandler];
        NSLog(@"error saving");
    }
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
	
}

@end
