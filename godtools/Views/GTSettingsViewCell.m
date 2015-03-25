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
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) addSeparatorWithCellHeight:(CGFloat)cellHeight{
   /* UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
    separatorLineView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:separatorLineView];*/
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight - 0.5, self.bounds.size.width, 0.5)];
    bottomLineView.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:bottomLineView];
}

-(void)setAsLanguageSelector{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.indentationLevel = 10;
    self.label.textColor = [UIColor blueColor];
    
    //    [super layoutSubviews];
    
//    CGRect textLabelFrame = self.label.frame;
//    textLabelFrame.origin.x = 60.0f;
//    self.label.frame = textLabelFrame;
    
//    CGRect frame = self.label.frame;
//    self.label.frame = CGRectMake(frame.origin.x + 20, frame.origin.y, frame.size.width - 20, frame.size.height);
//    [self layoutSubviews];
   // self.indentationLevel = self.indentationLevel + 2;
   // [self layoutSubviews ];
}

@end
