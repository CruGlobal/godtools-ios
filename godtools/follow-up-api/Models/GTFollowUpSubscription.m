//
//  GTFollowUpSubscription.m
//  godtools
//
//  Created by Ryan Carlson on 4/1/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import "GTFollowUpSubscription.h"

@implementation GTFollowUpSubscription

- (NSArray *)loadSubscriptionsNeedingAPITranmission {
    return [GTFollowUpSubscription MR_findAll];
}


- (instancetype)createNewSubscription {
    GTFollowUpSubscription *subscription = [GTFollowUpSubscription MR_createEntity];
    subscription.recordedTimestamp = [NSDate date];
    
    return subscription;
}


- (instancetype)createNewSubscriptionForEmail:(NSString *)emailAddress toRoute:(NSString *)routeId {
    GTFollowUpSubscription *subscription = [self createNewSubscription];
    subscription.emailAddress = emailAddress;
    subscription.routeId = routeId;
    
    return subscription;
}


- (instancetype)createNewSubscriptionForEmail:(NSString *)emailAddress toRoute:(NSString *)routeId withContext:(NSString *)contextId andFollowUp:(NSString *)followUpId {
    GTFollowUpSubscription *subscription = [self createNewSubscriptionForEmail:emailAddress
                                                                       toRoute:routeId];
    subscription.contextId = contextId;
    subscription.followUpId = followUpId;
    
    return subscription;
}

- (instancetype)createNewSubscriptionForEmail:(NSString *)emailAddress inLanguage:(NSString *)language toRoute:(NSString *) routeId {
    GTFollowUpSubscription *subscription = [self createNewSubscriptionForEmail:emailAddress
                                                                       toRoute:routeId];
    
    subscription.languageCode = language;
    
    return subscription;
}

@end
