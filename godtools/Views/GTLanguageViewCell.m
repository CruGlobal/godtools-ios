//
//  GTLanguageViewCell.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTLanguageViewCell.h"

@interface GTLanguageViewCell()

@property (nonatomic) BOOL downloading;

- (void)addAccessoryViewWithTarget:(id)target selector:(SEL)selector;

@end

@implementation GTLanguageViewCell

- (void)awakeFromNib {
    // Initialization code
	
	self.languageName.textColor = [UIColor whiteColor];
	self.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha: .1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)isDownloading{
    return self.downloading;
}

- (void) setDownloadingField:(BOOL)downloading {
    self.downloading = downloading;
}

- (void)configureWithLanguage:(GTLanguage *)language target:(id)target selector:(SEL)selector {
	
	self.language = language;
	NSString *localizedLanguageName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:language.code];
	self.languageName.text = ( [localizedLanguageName isEqualToString:language.code] ? language.name.capitalizedString : localizedLanguageName.capitalizedString );
	
	self.checkBox.hidden = YES;
	self.errorIcon.hidden = YES;
	
	// Create custom accessory view with action selector
	if(!language.downloaded) {
		[self addAccessoryViewWithTarget:target selector:selector];
	} else {
		self.accessoryView = nil;
	}
	
}

- (void)addAccessoryViewWithTarget:(id)target selector:(SEL)selector {
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(0.0f, 0.0f, 150.0f, 25.0f);
	
	[button setTitle:NSLocalizedString(@"download", nil)
			forState:UIControlStateNormal];
	
	[button setTitleColor: [UIColor whiteColor]
				 forState:UIControlStateNormal];
	
	[button addTarget:target
			   action:selector
	 forControlEvents:UIControlEventTouchUpInside];
	
	self.accessoryView = button;
	
}

@end
