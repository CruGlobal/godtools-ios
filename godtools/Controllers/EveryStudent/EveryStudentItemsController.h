//
//  EveryStudentItemsController.h
//  God Tools
//
//  Created by Michael Harrison on 7/07/11.
//  Copyright 2011 CCCA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EveryStudentArticleView.h"

@interface EveryStudentItemsController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)	NSMutableArray			*arrayOfTableData;
@property (nonatomic, strong)	EveryStudentArticleView	*articleView;
@property (nonatomic, weak)		IBOutlet UITableView	*itemsTable;
@property (nonatomic, strong)	NSString				*language;
@property (nonatomic, strong)	NSString				*package;

- (id)initWithArrayOfItems:(NSMutableArray *)items;

@end
