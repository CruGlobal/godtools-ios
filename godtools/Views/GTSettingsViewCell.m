//
//  GTSettingsViewCell.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTSettingsViewCell.h"

@implementation GTSettingsViewCell

- (void)awakeFromNib {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.label.numberOfLines = 0;
    self.label.lineBreakMode = UILineBreakModeWordWrap;
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

-(void)setAsLanguageSelector{
//    CGRect frame = self.label.frame;
//    self.label.frame = CGRectMake(frame.origin.x + 20, frame.origin.y, frame.size.width - 20, frame.size.height);
//    [self layoutSubviews];
    self.indentationLevel = self.indentationLevel + 2;
    [self layoutSubviews ];
}

@end
