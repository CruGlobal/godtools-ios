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
	
	//self.imageView.frame = CGRectMake(10, 10, 20.0, 20.0);
	//self.imageView.alpha = 0.25;
	
}

-(void)drawRect:(CGRect)drawingBoundary {
	
	CGRect rect = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//draw boundary
	CGContextBeginPath(context);
	
	//CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.5] CGColor]);
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:(228.0/255.0) green:(229.0/255.0) blue:(231.0/255.0) alpha:1.0] CGColor]);
	CGContextSetLineWidth(context, 2.0);
	
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect)-1);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-1);
	
	CGContextStrokePath(context);;
	
}

@end
