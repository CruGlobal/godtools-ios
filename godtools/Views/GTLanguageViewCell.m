//
//  GTLanguageViewCell.m
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTLanguageViewCell.h"

@interface GTLanguageViewCell()

@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) id parameter;

- (void)configureWithLanguage:(GTLanguage *)language buttonText:(NSString *)buttonText target:(id)target selector:(SEL)selector parameter:(id)parameter;
- (void)addAccessoryViewWithButtonText:(NSString *)buttonText;
- (void)callTargetSelectorForAccessory:(id)accessory;

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

- (void)setDownloadingField:(BOOL)downloading {
    self.downloading = downloading;
}

- (void)configureWithLanguage:(GTLanguage *)language buttonText:(NSString *)buttonText target:(id)target selector:(SEL)selector parameter:(id)parameter {
	
	self.language	= language;
	self.target		= target;
	self.selector	= selector;
	self.parameter	= parameter;
	NSString *localizedLanguageName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:language.code];
	self.languageName.text = ( !localizedLanguageName || [localizedLanguageName isEqualToString:language.code] ? language.name.capitalizedString : localizedLanguageName.capitalizedString );
	
	self.checkBox.hidden = YES;
	self.errorIcon.hidden = YES;
	
	// Create custom accessory view with action selector
	if(buttonText && self.target && self.selector) {
		[self addAccessoryViewWithButtonText:buttonText];
	} else {
		self.accessoryView = nil;
	}
	
}

- (void)addAccessoryViewWithButtonText:(NSString *)buttonText {
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(0.0f, 0.0f, 150.0f, 25.0f);
	
	[button setTitle:( buttonText ? buttonText : NSLocalizedString(@"download", nil) )
			forState:UIControlStateNormal];
	
	[button setTitleColor: [UIColor whiteColor]
				 forState:UIControlStateNormal];
	
	[button addTarget:self
			   action:@selector(callTargetSelectorForAccessory:)
	 forControlEvents:UIControlEventTouchUpInside];
	
	self.accessoryView = button;
	
}

- (void)callTargetSelectorForAccessory:(id)accessory {
	
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	if (self.parameter) {
		
		if ([self.target respondsToSelector:self.selector]) {
			[self.target performSelector:self.selector withObject:self.parameter];
		}
		
	} else {
		
		if ([self.target respondsToSelector:self.selector]) {
			[self.target performSelector:self.selector];
		}
		
	}
#pragma clang diagnostic pop
	
}

@end
