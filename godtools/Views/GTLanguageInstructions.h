//
//  GTLanguageInstructions.h
//  godtools
//
//  Created by Ryan Carlson on 4/7/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//


@interface GTLanguageInstructions : NSObject

-(void)showIntructionsInView:(UIView *)view;
-(void)stopAnimations;

@end

@protocol SNInstructionsDelegate <NSObject>

@optional
- (void)instructionAnimationsComplete;

@end