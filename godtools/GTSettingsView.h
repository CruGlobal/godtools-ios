//
//  GTSettingsView.h
//  godtools
//
//  Created by Ryan Carlson on 3/3/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTBaseView.h"
@protocol GTSettingsViewDelegate <NSObject>
@required
-(void)chooseLanguageButtonPressed;
-(void)chooseParallelLanguageButtonPressed;
@end

@interface GTSettingsView : GTBaseView

@property (strong,nonatomic) id<GTSettingsViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *chooseLanguageButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseParallelLanguageButton;

@property (strong, nonatomic) UILabel *languageNameLabel;
@property (strong, nonatomic) UILabel *parallelLanguageNameLabel;

- (IBAction)chooseLanguageButtonPressed:(id)sender;
- (IBAction)chooseParallelLanguageButtonPressed:(id)sender;

@end