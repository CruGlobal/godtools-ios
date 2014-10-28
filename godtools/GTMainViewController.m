//
//  GTMainViewController.m
//  godtools
//
//  Created by Michael Harrison on 3/13/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTMainViewController.h"
#import "GTDataImporter.h"

@interface GTMainViewController ()

@end

@implementation GTMainViewController

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	[[GTDataImporter sharedImporter] updateMenuInfo];
	
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
	
	
}

@end
