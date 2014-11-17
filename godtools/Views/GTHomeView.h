//
//  GTHomeView.h
//  godtools
//
//  Created by Claudine Bael on 11/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GTHomeViewDelegate <NSObject>
@required
-(void)settingsButtonPressed;
@end


@interface GTHomeView : UIView

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) id<GTHomeViewDelegate> delegate;
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
- (IBAction)settingsButtonPressed:(id)sender;


-(void)initDownloadIndicator;
-(void)showDownloadIndicator;
-(void)hideDownloadIndicator;

@end
