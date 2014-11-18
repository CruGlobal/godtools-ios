//
//  GTBaseView.h
//  godtools
//
//  Created by Claudine Bael on 11/17/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTBaseView : UIView

@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

-(void)initDownloadIndicator;
-(void)showDownloadIndicator;
-(void)hideDownloadIndicator;

@end
