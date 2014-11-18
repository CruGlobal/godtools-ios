//
//  GTHomeView.h
//  godtools
//
//  Created by Claudine Bael on 11/14/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTBaseView.h"
@protocol GTHomeViewDelegate <NSObject>
@required
-(void)settingsButtonPressed;
@end


@interface GTHomeView : GTBaseView

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) id<GTHomeViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
- (IBAction)settingsButtonPressed:(id)sender;

@end
