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

@end

@implementation GTLanguageViewCell

- (void)awakeFromNib {
    // Initialization code
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

@end
