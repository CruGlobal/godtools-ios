//
//  GTMainViewController.m
//  godtools
//
//  Created by Michael Harrison on 3/13/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTMainViewController.h"
#import "GTDataImporter.h"
#import "GTSettingsManager.h"
#import "RXMLElement.h"
#import "SSZipArchive.h"
#import "GTLanguage+Helper.h"
#import "GTPackage+Helper.h"
#import "TBXML.h"

@interface GTMainViewController ()
    @property (nonatomic, strong) GTViewController *godtoolsViewController;
    @property (nonatomic, strong) NSArray *resources;
@end

@implementation GTMainViewController

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	//[[GTDataImporter sharedImporter] updateMenuInfo];
    
    //NSString *configFile	= self.resources[0][@"keyConfigFile"];
    
    NSLog(@"%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //check if first launch
    if([defaults objectForKey:@"isDoneWithFirstLaunch"]==nil){
        NSLog(@"FIRST LAUNCH");
        
        //prepare initial content
        [self extractMetaData];
        [self extractBundle];
        [defaults setBool:YES forKey:@"isDoneWithFirstLaunch"];
        
    }else{
        NSLog(@"NOT FIRST LAUNCH");
    }
    
    //[self performSegueWithIdentifier:@"splashToHomeViewSegue" sender:self];
    
    
    //SAMPLE CODE FOR USING GTVIEWCONTROLLER -- put this at the home page
    //[self.godtoolsViewController loadResourceWithConfigFilename:configFile];

    //[self.navigationController pushViewController:self.godtoolsViewController animated:YES];
    //[self.navigationController setNavigationBarHidden:YES];
    
}

-(void)extractBundle{

    NSString *destinationPath ;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSError *error;
    
    destinationPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Packages/en"];
    NSLog(@"DESTINATION PATH: %@",destinationPath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]){   //Does directory already exist?
        if (![[NSFileManager defaultManager] createDirectoryAtPath:destinationPath withIntermediateDirectories:YES  attributes:nil error:&error]){
            NSLog(@"Create directory error: %@", error);
        }
    }
    
    NSString *temporaryFolderName	= [[NSUUID UUID] UUIDString];
    NSString* temporaryDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:temporaryFolderName];

    
    if (![[NSFileManager defaultManager] fileExistsAtPath:temporaryDirectory]){    //Does directory already exist?
        if (![[NSFileManager defaultManager] createDirectoryAtPath:temporaryDirectory withIntermediateDirectories:NO attributes:nil error:&error]){
            NSLog(@"Create directory error: %@", error);
        }
    }
    
    NSString* pathOfEnglishBundle              = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"zip"];
    
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

    GTLanguage *english = [GTLanguage languageWithCode:@"en" inContext:[GTStorage sharedStorage].backgroundObjectContext];
    english.name = @"English";
    
    NSMutableSet *packages = [english mutableSetValueForKey:@"packages"];
    [rootXML iterate:@"resource" usingBlock: ^(RXMLElement *resource) {
        
        GTPackage* package	= [GTPackage packageWithCode:[resource attribute:@"package"] language:english inContext:[GTStorage sharedStorage].backgroundObjectContext];
        
        NSLog(@"Pack: %@",package.code);
        
        
        package.name = [resource attribute:@"name"];
        package.configFile = [resource attribute:@"config"];
        package.icon = [resource attribute:@"icon"];
        package.status = [resource attribute:@"status"];
        package.localVersion = [NSNumber numberWithInt:[[resource attribute:@"version"] integerValue] ];
        package.latestVersion = [NSNumber numberWithInt:[[resource attribute:@"version"] integerValue] ];
        
        [packages addObject:package];
        
    }];
    
#warning need to move all files to Documents Directory after contents.xml has been parsed.
    
    //move to documents directory
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //
    //    NSString *txtPath = [documentsDirectory stringByAppendingPathComponent:@"txtFile.txt"];
    //
    //    if ([fileManager fileExistsAtPath:txtPath] == NO) {
    //        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"txtFile" ofType:@"txt"];
    //        [fileManager copyItemAtPath:resourcePath toPath:txtPath error:&error];
    //    }
    
    if (![[GTStorage sharedStorage].mainObjectContext save:&error]) {
        
        NSLog(@"error saving");
        
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:english.name forKey:@"mainLanguage"];
    
    [[GTSettingsManager sharedManager] setMainLanguage:english];
}

-(void)extractMetaData{
    NSError *error;
    NSString* pathOfMeta = [[NSBundle mainBundle] pathForResource:@"meta" ofType:@"xml"];
    
    RXMLElement *metaXML = [RXMLElement elementFromXMLData:[NSData dataWithContentsOfFile:pathOfMeta]];
    __block NSMutableSet *metaPackagesOfLanguage;
    
    [metaXML iterate:@"language" usingBlock: ^(RXMLElement *languageElement) {
        
        __block GTLanguage *language = [GTLanguage languageWithCode:[languageElement attribute:@"code"] inContext:[GTStorage sharedStorage].backgroundObjectContext];
        
        language.name = [languageElement attribute:@"name"];
        
        metaPackagesOfLanguage = [language mutableSetValueForKey:@"packages"];
        
        [languageElement iterate:@"packages.package" usingBlock: ^(RXMLElement *packageElement) {
            
            
            GTPackage* package	= [GTPackage packageWithCode:[packageElement attribute:@"code"] language:language inContext:[GTStorage sharedStorage].backgroundObjectContext];

            
            package.name = [packageElement attribute:@"name"];
            package.configFile = [packageElement attribute:@"config"];
            package.icon = [packageElement attribute:@"icon"];
            package.status = [packageElement attribute:@"status"];
            package.localVersion = [NSNumber numberWithInt:[[packageElement attribute:@"version"] integerValue] ];
            package.latestVersion = [NSNumber numberWithInt:[[packageElement attribute:@"version"] integerValue] ];
            
            [metaPackagesOfLanguage addObject:package];
        }];
        
    }];

    if (![[GTStorage sharedStorage].mainObjectContext save:&error]) {
        NSLog(@"error saving");
    }
}

- (GTViewController *)godtoolsViewController {
    
    if (!_godtoolsViewController) {
        NSString *configFile	= self.resources[0][@"keyConfigFile"];
        GTFileLoader *fileLoader = [GTFileLoader fileLoader];
        fileLoader.language		= @"en";
        GTShareViewController *shareViewController = [[GTShareViewController alloc] init];
        GTPageMenuViewController *pageMenuViewController = [[GTPageMenuViewController alloc] initWithFileLoader:fileLoader];
        GTAboutViewController *aboutViewController = [[GTAboutViewController alloc] initWithDelegate:self fileLoader:fileLoader];
        
        [self willChangeValueForKey:@"godtoolsViewController"];
        _godtoolsViewController	= [[GTViewController alloc] initWithConfigFile:configFile
                                                                    fileLoader:fileLoader
                                                           shareViewController:shareViewController
                                                        pageMenuViewController:pageMenuViewController
                                                           aboutViewController:aboutViewController
                                                                      delegate:self];
        [self didChangeValueForKey:@"godtoolsViewController"];
        
    }
    
    return _godtoolsViewController;
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
	
}

@end
