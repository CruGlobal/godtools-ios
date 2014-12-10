//
//  GTHomeViewCell.m
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTHomeViewCell.h"

@implementation GTHomeViewCell

- (void)awakeFromNib {
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) addSeparator{
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
    separatorLineView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:separatorLineView];
}

-(void) setUpBackground:(int)isEven{
    if(isEven){
        self.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
    }
}

@end
