//
//  EveryStudentSearchCell.m
//  God Tools
//
//  Created by Michael Harrison on 7/07/11.
//  Copyright 2011 CCCA. All rights reserved.
//

#import "EveryStudentSearchCell.h"


@implementation EveryStudentSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
    if (self) {
		// Initialization code
		self.nameLabel						= [[UILabel alloc] init];
		self.nameLabel.textAlignment		= NSTextAlignmentLeft;
		self.nameLabel.font					= [UIFont systemFontOfSize:16];
		self.nameLabel.backgroundColor		= [UIColor clearColor];
		self.searchResultLabel				= [[UILabel alloc] init];
		self.searchResultLabel.textAlignment= NSTextAlignmentLeft;
		self.searchResultLabel.font			= [UIFont systemFontOfSize:12];
		self.searchResultLabel.textColor	= [UIColor darkGrayColor];
		self.searchResultLabel.backgroundColor = [UIColor clearColor];
		//temp								= [[UIImageView alloc] init];
		//self.iconImageView					= temp;
		//[temp release];
		[self.contentView addSubview:self.nameLabel];
		[self.contentView addSubview:self.searchResultLabel];
		//[self.contentView addSubview:self.iconImageView];
		
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect contentRect			= self.contentView.bounds;
	CGFloat boundsX				= contentRect.origin.x;
	CGRect frame				= CGRectMake(boundsX+55 ,0, 250, 25);
	self.nameLabel.frame		= frame;
	
	frame						= CGRectMake(boundsX+55 ,25, 250, 15);
	self.searchResultLabel.frame= frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)drawRect:(CGRect)drawingBoundary {
	
	CGRect rect = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//draw boundary
	CGContextBeginPath(context);
	
	//CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.5] CGColor]);
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:(228.0/255.0) green:(229.0/255.0) blue:(231.0/255.0) alpha:1.0] CGColor]);
	CGContextSetLineWidth(context, 1.0);
	
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect)-1);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-1);
	
	CGContextStrokePath(context);;
	
}

@end
