//
//  GTHomeView.h
//  godtools
//
//  Created by Claudine Bael on 11/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTBaseView.h"
@protocol GTHomeViewDelegate <NSObject>
@required
-(void)settingsButtonPressed;
@end


@interface GTHomeView : GTBaseView

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) id<GTHomeViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *translatorModeLabel;

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIView *refreshDraftsView;

- (IBAction)settingsButtonPressed:(id)sender;

- (void) hideInstructionsOverlay:(BOOL) animated;
- (void) setIconImage:(UIImage *)image;

@end
