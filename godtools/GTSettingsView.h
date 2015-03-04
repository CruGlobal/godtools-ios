//
//  GTSettingsView.h
//  godtools
//
//  Created by Ryan Carlson on 3/3/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTBaseView.h"
@protocol GTSettingsViewDelegate <NSObject>
@required

@end

@interface GTSettingsView : GTBaseView
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end