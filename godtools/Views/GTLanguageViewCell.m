//
//  GTLanguageViewCell.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTLanguageViewCell.h"

@interface GTLanguageViewCell()

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *checkmarkButton;
@property (weak, nonatomic, readwrite) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *selectedStateView;


@end

@implementation GTLanguageViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
	self.languageName.textColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setIsDownloading:(BOOL)isDownloading {
    if (isDownloading && ![self.activityIndicator isAnimating]) {
        [self.activityIndicator startAnimating];
        self.downloadButton.hidden = YES;
    }
    
    if (!isDownloading && [self.activityIndicator isAnimating]) {
        [self.activityIndicator stopAnimating];
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    self.checkmarkButton.hidden = !isSelected;
    self.selectedStateView.hidden = !isSelected;
    
    // don't show download button if cell is selected
    if (isSelected) {
        self.downloadButton.hidden = YES;
    }
}

- (void)configureWithLanguage:(GTLanguage *)language {
    self.language = language;
    
    NSString *localizedLanguageName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:language.code];
    self.languageName.text = ( !localizedLanguageName || [localizedLanguageName isEqualToString:language.code] ? language.name.capitalizedString : localizedLanguageName.capitalizedString );
    
    //download button is hidden if the language is downloaded AND the language has no updates
    self.downloadButton.hidden = [language.downloaded boolValue] && !language.hasUpdates;
}

- (IBAction)downloadButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate languageViewCellDownloadButtonWasPressed:self];
    }
}

@end
