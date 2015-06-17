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

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) NSNumber *packageIsPresent;

@property (weak, nonatomic) IBOutlet UIButton *translatorOptionsButton;
@property (weak, nonatomic) IBOutlet UIImageView *translatorOptionsImage;
@property (weak, nonatomic) IBOutlet UIView *publishDeleteOptionsView;
@property (weak, nonatomic) IBOutlet UIView *createOptionsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalLayoutConstraint;

-(IBAction)showTranslatorOptionsButtonPressed:(id)sender;
-(IBAction)publishDraftButtonPressed:(id)sender;
-(IBAction)deleteDraftButtonPressed:(id)sender;
-(IBAction)createDraftButtonPressed:(id)sender;

@end

@implementation GTHomeViewCell

- (void)awakeFromNib {
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.numberOfLines = 0;
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

-(void) showPreviewModeLayoutWithPackagePresent:(BOOL) packagePresent
                             package:(GTPackage *) package {
    self.titleLabel.text = package.name;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.packageIsPresent = [NSNumber numberWithBool:packagePresent];
    
    if(packagePresent) {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.85];
        
        NSString *filePathToIcon = [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:package.icon];
        self.icon.image = [UIImage imageWithContentsOfFile: filePathToIcon];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.15];
        
        self.icon.image = nil;
    }
    
    self.publishDeleteOptionsView.hidden = YES;
    self.createOptionsView.hidden = YES;
    self.verticalLayoutConstraint.constant = 2.0;
    self.backgroundView = nil;
    
    self.translatorOptionsButton.hidden = NO;
    self.translatorOptionsImage.hidden = NO;
}

-(void) showNormalModeLayoutWithLightBackground:(BOOL) lightBackground
                            package:(GTPackage *) package {
    self.titleLabel.text = package.name;
    
    NSString *filePathToIcon = [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:package.icon];
    self.icon.image = [UIImage imageWithContentsOfFile: filePathToIcon];
    
    if(lightBackground){
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.45];
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.65];
    }
    
    self.publishDeleteOptionsView.hidden = YES;
    self.createOptionsView.hidden = YES;
    self.verticalLayoutConstraint.constant = 2.0;
    self.backgroundView = nil;
    
    [self.contentView.layer setBorderColor:nil];
    [self.contentView.layer setBorderWidth:0.0];
    
    self.translatorOptionsButton.hidden = YES;
    self.translatorOptionsImage.hidden = YES;
}

-(void) showEveryStudentLayout {
    self.titleLabel.text = @"Every Student";
    self.icon.image = [UIImage imageNamed:@"GT4_HomeScreen_ESIcon_.png"];
    
    self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.45];
    
    self.publishDeleteOptionsView.hidden = YES;
    self.createOptionsView.hidden = YES;
    self.verticalLayoutConstraint.constant = 2.0;
    self.backgroundView = nil;
    
    [self.contentView.layer setBorderColor:nil];
    [self.contentView.layer setBorderWidth:0.0];
    
    self.translatorOptionsButton.hidden = YES;
    self.translatorOptionsImage.hidden = YES;
}

- (void) showTranslatorOptions {
    if(![self.packageIsPresent boolValue]) {
        self.createOptionsView.hidden = NO;
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GT4_HomeScreen_PreviewCell_Missing_Bkgd.png"]];
    } else {
        self.publishDeleteOptionsView.hidden = NO;
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GT4_HomeScreen_PreviewCell_Bkgd.png"]];
    }
    self.verticalLayoutConstraint.constant = 33.0;
    self.backgroundColor = [UIColor clearColor];
}

-(void) setCustomFont:(NSString *) fontName {
    self.titleLabel.font = [UIFont fontWithName:fontName size:self.titleLabel.font.pointSize];
}

-(void) translatorOptionsButtonPressed:(id)sender {
    [self.delegate translatorOptionsButtonPressed:self.sectionIdentifier];
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
