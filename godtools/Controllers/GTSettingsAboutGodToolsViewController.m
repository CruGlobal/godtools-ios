//
//  GTSettingsAboutGodToolsViewController.m
//  godtools
//
//  Created by Claudine Bael on 12/19/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTSettingsAboutGodToolsViewController.h"
#import "GTSettingsAboutGodToolsView.h"

@interface GTSettingsAboutGodToolsViewController ()
@property GTSettingsAboutGodToolsView *aboutView;
@property UITapGestureRecognizer *tap;
@end

@implementation GTSettingsAboutGodToolsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.aboutView = (GTSettingsAboutGodToolsView*) [[[NSBundle mainBundle] loadNibNamed:@"GTSettingsAboutGodToolsView" owner:nil options:nil]objectAtIndex:0];
    self.aboutView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view = self.aboutView;
    
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissAbout)];
    
    self.tap.delegate = self;
    
    [self.aboutView addGestureRecognizer:self.tap];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dismissAbout{
    NSLog(@"dismiss");
    
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}



@end
