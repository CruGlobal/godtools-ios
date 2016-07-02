//
//  GTAccessCodeController.h
//  godtools
//
//  Created by Ryan Carlson on 3/5/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTAccessCodeController : UIViewController<UITextFieldDelegate>

-(void)authorizeTranslatorAlert:(NSNotification *) notification;

@end