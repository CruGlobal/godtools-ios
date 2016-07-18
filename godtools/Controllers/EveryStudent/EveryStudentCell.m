//
//  EveryStudentCell.m
//  Snuffy
//
//  Created by Michael Harrison on 6/14/12.
//  Copyright (c) 2012 CCCA. All rights reserved.
//

#import "EveryStudentCell.h"

@implementation EveryStudentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.disclosure = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 21, self.frame.size.height)];
        UIImage *image = [UIImage imageNamed:@"GT4_SettingsScreen_RightArrow_"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.frame = CGRectMake(self.disclosure.frame.origin.x, self.disclosure.frame.origin.y, self.disclosure.frame.size.width, self.disclosure.frame.size.height);
        [self.disclosure addSubview:imageView];
        imageView.backgroundColor = [UIColor clearColor];
        self.disclosure.backgroundColor = [UIColor clearColor];
        [self addSubview:self.disclosure];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
	
	[super layoutSubviews];
    
    CGRect frame = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height-14.0);
    CGRect imageframe = self.imageView.frame;
    self.imageView.frame = CGRectMake(imageframe.origin.x, imageframe.origin.y-7.0, imageframe.size.width, imageframe.size.height);
    self.accessoryType = UITableViewCellAccessoryNone;
    self.disclosure.frame = CGRectMake(self.frame.size.width-31, 0, 21, self.frame.size.height);
	
}

-(void)drawRect:(CGRect)drawingBoundary {
	
	CGRect rect = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//draw boundary
	CGContextBeginPath(context);
	
	//CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.5] CGColor]);
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:(228.0/255.0) green:(229.0/255.0) blue:(231.0/255.0) alpha:0.0] CGColor]);
	CGContextSetLineWidth(context, 2.0);
	
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect)-1);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-1);
	
	CGContextStrokePath(context);;
	
}

@end
