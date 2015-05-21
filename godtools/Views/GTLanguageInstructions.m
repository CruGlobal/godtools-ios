//
//  GTLanguageInstructions.m
//  godtools
//
//  Created by Ryan Carlson on 4/7/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLanguageInstructions.h"

@interface GTLanguageInstructions()

@property	(nonatomic, strong) UIView					*parentView;
@property	(nonatomic, strong) UIImageView				*pointerImage;
@property   (nonatomic, strong) UIImageView             *tintedBackground;
@property	(nonatomic, strong) UIImageView				*pointerShadowImage;
@property	(nonatomic, strong) UIImageView				*tapImage;

@property	(nonatomic, weak)	id<SNInstructionsDelegate> delegate;

@property	(nonatomic, assign)	NSInteger				counter;

@end

@implementation GTLanguageInstructions

- (instancetype)init {
    
    self	= [super init];
    
    if (self != nil) {
        
        self.pointerImage	= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GTInstructions_Hand_Pointer_Small"]];
        self.tintedBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay"]];
        self.tapImage	= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GTInstructions_Hand_Pointer_Tap_Circle"]];
        
        self.counter = 0;
    }
    
    return  self;
    
}

-(void) showIntructionsInView:(UIView *)view {
    self.counter++;
    
    self.parentView	= view;
    
    self.pointerImage.center	= self.parentView.center;
    CGRect pointerFrame			= self.pointerImage.frame;
    pointerFrame.origin.x		+= (self.parentView.frame.size.width);
    self.pointerImage.frame		= pointerFrame;
    self.pointerImage.alpha		= 0.0;
    
    self.pointerShadowImage.frame		= pointerFrame;
    self.pointerShadowImage.alpha		= 0.0;
    
    [self.parentView addSubview:self.tintedBackground];
    [self.parentView addSubview:self.pointerImage];
    [self.parentView insertSubview:self.pointerShadowImage belowSubview:self.pointerImage];
    
    //fade in
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fadeInSwipeDidStop)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.777];
    
    //Animate
    [UIView commitAnimations];
}

- (void)fadeInSwipeDidStop {
    
    CGPoint pointerCenter		= self.pointerImage.center;
    pointerCenter.x				-= (self.parentView.frame.size.width * 0.25);
    
    // first half of swipe in the direction of text direction
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(firstHalfOfSwipeDidStop)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.155];
    
    self.pointerImage.transform	= CGAffineTransformMakeScale(0.9, 0.9);
    self.pointerImage.center	= pointerCenter;
    
    self.pointerShadowImage.transform	= CGAffineTransformMakeScale(0.95, 0.95);
    self.pointerShadowImage.alpha		= 0.5;
    self.pointerShadowImage.center	= pointerCenter;
    
    //Animate
    [UIView commitAnimations];
    
}

- (void)firstHalfOfSwipeDidStop {
    
    CGPoint pointerCenter		= self.pointerImage.center;
    pointerCenter.x				-= (self.parentView.frame.size.width * 0.25);
    
    // first half of swipe in the direction of text direction
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(secondHalfOfSwipeDidStop)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:.777];
    
    self.pointerImage.transform	= CGAffineTransformMakeScale(1.0, 1.0);
    self.pointerImage.center	= pointerCenter;
    
    self.pointerShadowImage.transform	= CGAffineTransformMakeScale(1.0, 1.0);
    self.pointerShadowImage.alpha		= 1.0;
    self.pointerShadowImage.center	= pointerCenter;
    
    //Animate
    [UIView commitAnimations];
    
}

- (void)secondHalfOfSwipeDidStop {
    
    // first half of swipe in the direction of text direction
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fadeOutSwipeDidStop)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:.777];
    
    self.pointerImage.alpha		= 0.0;
    
    self.pointerShadowImage.alpha		= 0.0;
    
    //Animate
    [UIView commitAnimations];
    
}

- (void)fadeOutSwipeDidStop {
    
    [self performSelector:@selector(startTapAnimation) withObject:nil afterDelay:0.4];
    
}

- (void)startTapAnimation {
    
    self.pointerImage.center	= self.parentView.center;
    self.pointerShadowImage.center	= self.parentView.center;
    
    // first half of swipe in the direction of text direction
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fadeInTapDidStop)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:.777];
    
    self.pointerImage.alpha		= 1.0;
    
    self.pointerShadowImage.alpha		= 1.0;
    
    //Animate
    [UIView commitAnimations];
    
}

- (void)fadeInTapDidStop {
    
    // first half of swipe in the direction of text direction
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(firstHalfOfTapDidStop)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.25];
    
    self.pointerImage.transform	= CGAffineTransformMakeScale(0.7, 0.7);
    
    self.pointerShadowImage.transform	= CGAffineTransformMakeScale(0.75, 0.75);
    self.pointerShadowImage.alpha		= 0.5;
    
    //Animate
    [UIView commitAnimations];
    
}

- (void)firstHalfOfTapDidStop {
    
    CGPoint tapCenter		= self.pointerImage.center;
    tapCenter.x				-= 36;
    tapCenter.y				-= 62;
    self.tapImage.center	= tapCenter;
    self.tapImage.alpha		= 1.0;
    self.tapImage.transform	= CGAffineTransformMakeScale(1.0, 1.0);
    [self.parentView insertSubview:self.tapImage belowSubview:self.pointerImage];
    
    // first half of swipe in the direction of text direction
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(secondHalfOfTapDidStop)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:UINavigationControllerHideShowBarDuration];
    
    self.pointerImage.transform	= CGAffineTransformMakeScale(1.0, 1.0);
    self.pointerImage.alpha		= 0.0;
    
    self.pointerShadowImage.transform	= CGAffineTransformMakeScale(1.0, 1.0);
    self.pointerShadowImage.alpha		= 0.0;
    
    self.tapImage.transform		= CGAffineTransformMakeScale(2.0, 2.0);
    self.tapImage.alpha			= 0.0;
    
    //Animate
    [UIView commitAnimations];
    
}

- (void)secondHalfOfTapDidStop {
    
    [self.pointerImage removeFromSuperview];
    [self.pointerShadowImage removeFromSuperview];
    [self.tintedBackground removeFromSuperview];
    [self.tapImage removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(instructionAnimationsComplete)]) {
        
        [self.delegate performSelector:@selector(instructionAnimationsComplete)];
        
    }
    
    
    self.parentView	= nil;
    self.delegate	= nil;
    
}

-(void) stopAnimations {
    
}

@end