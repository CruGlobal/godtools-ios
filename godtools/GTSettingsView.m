//
//  GTSettingsView.m
//  godtools
//
//  Created by Ryan Carlson on 3/3/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import "GTSettingsView.h"

@implementation GTSettingsView

- (IBAction)doneButtonPressed:(id)sender {
    if(self.delegate){
        if([self.delegate respondsToSelector:@selector(doneButtonPressed)]){
            [self.delegate doneButtonPressed];
        }
    }
}
@end