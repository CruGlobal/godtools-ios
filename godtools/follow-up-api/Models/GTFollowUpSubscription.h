//
//  GTFollowUpSubscription.h
//  godtools
//
//  Created by Ryan Carlson on 4/1/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


NS_ASSUME_NONNULL_BEGIN

@interface GTFollowUpSubscription : NSManagedObject

- (NSArray *)loadSubscriptionsNeedingAPITranmission;

- (instancetype)createNewSubscription;
- (instancetype)createNewSubscriptionForEmail:(NSString *)emailAddress toRoute:(NSString *)routeId;
- (instancetype)createNewSubscriptionForEmail:(NSString *)emailAddress toRoute:(NSString *)routeId withContext:(NSString *)contextId andFollowUp:(NSString *)followUpId;
- (instancetype)createNewSubscriptionForEmail:(NSString *)emailAddress inLanguage:(NSString *)language toRoute:(NSString *) routeId;
@end

NS_ASSUME_NONNULL_END

#import "GTFollowUpSubscription+CoreDataProperties.h"