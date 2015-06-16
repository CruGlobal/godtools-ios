//
//  GTHomeViewCell.m
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTHomeViewCell.h"

@interface GTHomeViewCell ()

-(IBAction)showTranslatorOptionsButtonPressed:(id)sender;
-(IBAction)publishDraftButtonPressed:(id)sender;
-(IBAction)deleteDraftButtonPressed:(id)sender;
-(IBAction)createDraftButtonPressed:(id)sender;

@end

@implementation GTHomeViewCell

- (void)awakeFromNib {
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setUpBackground:(int)isEven :(int)isTranslatorMode :(int)isMissingDraft{
    if(isMissingDraft && isTranslatorMode) {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.15];
    } else if(isTranslatorMode) {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.85];
    } else if(isEven){
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.45];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.65];
    }
}

-(void) showTranslatorOptionsButtonPressed:(id)sender {
    [self.delegate showTranslatorOptionsButtonPressed:self.sectionIdentifier];
}

-(void) publishDraftButtonPressed:(id)sender {
    [self.delegate publishDraftButtonPressed:self.sectionIdentifier];
}

-(void) deleteDraftButtonPressed:(id)sender {
    [self.delegate deleteDraftButtonPressed:self.sectionIdentifier];
}

-(void) createDraftButtonPressed:(id)sender {
    [self.delegate createDraftButtonPressed:self.sectionIdentifier];
}

@end
