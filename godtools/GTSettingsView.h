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
-(void)doneButtonPressed;
@end

@interface GTSettingsView : GTBaseView

@property (strong,nonatomic) id<GTSettingsViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)doneButtonPressed:(id)sender;

@end