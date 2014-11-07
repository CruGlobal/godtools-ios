//
//  GTRendererController.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTRendererController.h"
#import <GTViewController/GTFileLoader.h>
#import <GTViewController/GTPageMenuViewController.h>
#import <GTViewController/GTShareViewController.h>
#import <GTViewController/GTAboutViewController.h>

@interface GTRendererController ()

@end

@implementation GTRendererController

+ (id)sharedInstance {
    
    static GTRendererController *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedManager = [[GTRendererController alloc] init];
        
    });
    
    return sharedManager;
}

-(id)init{
    self = [super init];
    if (self != nil) {
        NSString *configFile = 
        GTFileLoader *fileLoader = [GTFileLoader fileLoader];
        fileLoader.language		= [[NSUserDefaults standardUserDefaults] stringForKey:@"mainLanguage"];
        GTShareViewController *shareViewController = [[GTShareViewController alloc] init];
        GTPageMenuViewController *pageMenuViewController = [[GTPageMenuViewController alloc] initWithFileLoader:fileLoader];
        GTAboutViewController *aboutViewController = [[GTAboutViewController alloc] initWithDelegate:self fileLoader:fileLoader];
        
        [self willChangeValueForKey:@"godtoolsViewController"];
        self	= [self initWithConfigFile:configFile
                              fileLoader:fileLoader
                     shareViewController:shareViewController
                  pageMenuViewController:pageMenuViewController
                     aboutViewController:aboutViewController
                                delegate:self];
        [self didChangeValueForKey:@"godtoolsViewController"];
    }
    return self;
}

//Must be called after english bundle is done
-(void)initializeWithConfigFile:(NSString*)configFile languageCode:(NSString*)code{



}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
