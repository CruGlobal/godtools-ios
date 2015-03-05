//
//  GTSettingsView.m
//  godtools
//
//  Created by Ryan Carlson on 3/3/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import "GTSettingsView.h"

@implementation GTSettingsView

- (IBAction)chooseLanguageButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(chooseLanguageButtonPressed)]) {
        [self.delegate chooseLanguageButtonPressed];
    }
}

- (IBAction)chooseParallelLanguageButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(chooseParallelLanguageButtonPressed)]) {
        [self.delegate chooseParallelLanguageButtonPressed];
    }
}

- (IBAction)previewModeSwitchButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(previewModeSwitchPressed)]) {
        [self.delegate previewModeSwitchPressed];
    }
}
@end