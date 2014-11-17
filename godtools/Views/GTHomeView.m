//
//  GTHomeView.m
//  godtools
//
//  Created by Claudine Bael on 11/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTHomeView.h"

@implementation GTHomeView

-(void)initDownloadIndicator{
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, self.frame.size.height - 50.0f, self.frame.size.width - 20.0f, 40.0f)];
    self.loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.loadingView.clipsToBounds = YES;
    self.loadingView.layer.cornerRadius = 10.0;
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityView.frame = CGRectMake(10.0f, 10.0f, self.activityView.bounds.size.width, self.activityView.bounds.size.height);
    [self.loadingView addSubview:self.activityView];
    
    self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 10.0f, 130, 22)];
    self.loadingLabel.backgroundColor = [UIColor clearColor];
    self.loadingLabel.textColor = [UIColor whiteColor];
    self.loadingLabel.adjustsFontSizeToFitWidth = YES;
    self.loadingLabel.text = @"Downloading Resources...";
    [self.loadingView addSubview:self.loadingLabel];
    [self addSubview:self.loadingView];
    self.loadingView.hidden = YES;
}

-(void)showDownloadIndicator{
    self.loadingView.hidden = NO;
    [self.activityView startAnimating];
}

-(void)hideDownloadIndicator{
    self.loadingView.hidden = YES;
    [self.activityView stopAnimating];
}


- (IBAction)settingsButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(settingsButtonPressed)]){
        [self.delegate settingsButtonPressed];
    }

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
