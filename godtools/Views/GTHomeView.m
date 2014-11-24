//
//  GTHomeView.m
//  godtools
//
//  Created by Claudine Bael on 11/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTHomeView.h"

@implementation GTHomeView


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
