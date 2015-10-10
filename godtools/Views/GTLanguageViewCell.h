//
//  GTLanguageViewCell.h
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Modified by Lee Braddock.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLanguage+Helper.h"

@interface GTLanguageViewCell : UITableViewCell

@property (nonatomic, strong) GTLanguage *language;
@property (weak, nonatomic) IBOutlet UILabel *languageName;
@property (weak, nonatomic) IBOutlet UIImageView *checkBox;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *errorIcon;

-(BOOL) isDownloading;
-(void) setDownloadingField: (BOOL)downloading;

- (void)configureWithLanguage:(GTLanguage *)language buttonText:(NSString *)buttonText target:(id)target selector:(SEL)selector parameter:(id)parameter;

@end
