//
//  GTHomeView.m
//  godtools
//
//  Created by Claudine Bael on 11/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTHomeView.h"

@interface GTHomeView()

@property (weak, nonatomic) IBOutlet UIImageView *setLanguageImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pickToolImageView;
@property (weak, nonatomic) IBOutlet UIView *instructionsOverlayView;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation GTHomeView

- (IBAction)settingsButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(settingsButtonPressed)]){
        [self.delegate settingsButtonPressed];
    }
}

- (void) hideInstructionsOverlay:(BOOL) animated {
    if(animated) {
        [UIView animateWithDuration: 1.0 delay:6.0 options:0 animations:^{
            self.instructionsOverlayView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.instructionsOverlayView.hidden = YES;
        }];
    } else {
        self.instructionsOverlayView.hidden = YES;
    }
}

- (void) showPreviewModeLayout {
    self.iconImageView.image = [UIImage imageNamed:@"GT4_Home_BookIcon_PreviewMode_"];
    self.translatorModeLabel.hidden = NO;
    self.refreshDraftsView.hidden = NO;
    [self.tableView setScrollEnabled:YES];
}

- (void) showNormalModeLayout {
    self.iconImageView.image = [UIImage imageNamed:@"GT4_Home_BookIcon_"];
    self.translatorModeLabel.hidden = YES;
    self.refreshDraftsView.hidden = YES;
    [self.tableView setScrollEnabled:NO];
}
@end
