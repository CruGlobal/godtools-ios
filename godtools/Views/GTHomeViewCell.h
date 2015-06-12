//
//  GTHomeViewCell.h
//  godtools
//
//  Created by Claudin.Bael on 11/6/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTPackage.h"

@protocol GTHomeViewCellDelegate
@required
-(void) showTranslatorOptionsButtonPressed:NSString;
-(void) publishDraftButtonPressed:NSString;
-(void) deleteDraftButtonPressed:NSString;
-(void) createDraftButtonPressed:NSString;
@end

@interface GTHomeViewCell : UITableViewCell

@property (strong, nonatomic) id<GTHomeViewCellDelegate> delegate;
@property (strong, nonatomic) NSString *sectionIdentifier;

-(void) showPreviewModeLayout:(BOOL) packagePresent
                             :(GTPackage *) package;

-(void) showNormalModeLayout:(BOOL) lightBackground
                            :(GTPackage *) package;

-(void) showEveryStudentLayout;

-(void) showTranslatorOptions;

-(void) setCustomFont:(NSString *) fontName;
@end
