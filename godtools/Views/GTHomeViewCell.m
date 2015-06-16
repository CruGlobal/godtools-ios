//
//  GTHomeViewCell.m
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTHomeViewCell.h"
#import "GTFileLoader.h"

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

-(void) showPreviewModeLayout:(BOOL) packagePresent
                             :(GTPackage *) package {
    self.titleLabel.text = package.name;
    
    if(packagePresent) {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.85];
        
        NSString *filePathToIcon = [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:package.icon];
        self.icon.image = [UIImage imageWithContentsOfFile: filePathToIcon];
        
        [self.contentView.layer setBorderColor:nil];
        [self.contentView.layer setBorderWidth:0.0];
        
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.15];
        
        self.icon.image = nil;
        
        [self.contentView.layer setBorderColor:[UIColor lightTextColor].CGColor];
        [self.contentView.layer setBorderWidth:1.0f];
    }
}

-(void) showNormalModeLayout:(BOOL) lightBackground
                            :(GTPackage *) package {
    self.titleLabel.text = package.name;
    
    NSString *filePathToIcon = [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:package.icon];
    self.icon.image = [UIImage imageWithContentsOfFile: filePathToIcon];
    
    if(lightBackground){
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.45];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.65];
    }
    
    [self.contentView.layer setBorderColor:nil];
    [self.contentView.layer setBorderWidth:0.0];
}

-(void) showEveryStudentLayout {
    self.titleLabel.text = @"Every Student";
    self.icon.image = [UIImage imageNamed:@"GT4_HomeScreen_ESIcon_.png"];
    
    self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.45];
    
    [self.contentView.layer setBorderColor:nil];
    [self.contentView.layer setBorderWidth:0.0];
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
