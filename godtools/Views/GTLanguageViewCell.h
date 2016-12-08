//
//  GTLanguageViewCell.h
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Modified by Lee Braddock.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLanguage.h"

@protocol GTLanguageViewCellDelegate <NSObject>
@required
- (void)languageViewCellDownloadButtonWasPressed:(id)sender;
@end

@interface GTLanguageViewCell : UITableViewCell

@property (nonatomic, strong) GTLanguage *language;
@property (weak, nonatomic) IBOutlet UILabel *languageName;

@property (strong, nonatomic) id<GTLanguageViewCellDelegate> delegate;

- (void)setIsDownloading:(BOOL)isDownloading;
- (void)setIsSelected:(BOOL)isSelected;

- (void)configureWithLanguage:(GTLanguage *)language;

@end
