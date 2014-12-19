//
//  GTSettingsAboutGodToolsView.h
//  godtools
//
//  Created by Claudine Bael on 12/19/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTBaseView.h"

@interface GTSettingsAboutGodToolsView : GTBaseView 

@property (weak, nonatomic) IBOutlet UIImageView *backgroundGradientImage;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *gotToolsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UILabel *emailMessageLabel;

@property (weak, nonatomic) IBOutlet UILabel *copyrightTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *kgpCopyrightLabel;
@property (weak, nonatomic) IBOutlet UILabel *satisfiedCopyrightLabel;

@end
