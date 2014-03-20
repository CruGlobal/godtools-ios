//
//  GTViewController.m
//  godtools
//
//  Created by Michael Harrison on 3/13/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTViewController.h"
#import "GTDataImporter.h"

@interface GTViewController ()

@end

@implementation GTViewController

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	[[GTDataImporter sharedImporter] updateMenuInfo];
	
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
	
	
}

@end
