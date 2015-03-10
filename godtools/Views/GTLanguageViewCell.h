//
//  GTLanguageViewCell.h
//  godtools
//
//  Created by Claudine Bael on 11/7/14.
//  Modified by Lee Braddock.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTLanguageViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *languageName;
@property (weak, nonatomic) IBOutlet UIImageView *checkBox;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
