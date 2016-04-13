//
//  GTFollowUpSubscription+CoreDataProperties.m
//  godtools
//
//  Created by Ryan Carlson on 4/1/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GTFollowUpSubscription+CoreDataProperties.h"

@implementation GTFollowUpSubscription (CoreDataProperties)

@dynamic emailAddress;
@dynamic followUpId;
@dynamic contextId;
@dynamic routeId;
@dynamic apiTransmissionTimestamp;
@dynamic apiTransmissionSuccess;
@dynamic languageCode;
@dynamic recordedTimestamp;

- (void)recordAPITransmissionSuccess:(NSNumber *)wasSuccessful atDatetime:(NSDate *)timestamp {
    self.apiTransmissionSuccess = wasSuccessful;
    self.apiTransmissionTimestamp = timestamp;
}

@end
