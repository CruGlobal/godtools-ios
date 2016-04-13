//
//  GTFollowUpSubscription+CoreDataProperties.h
//  godtools
//
//  Created by Ryan Carlson on 4/1/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GTFollowUpSubscription.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTFollowUpSubscription (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *emailAddress;
@property (nullable, nonatomic, retain) NSString *followUpId;
@property (nullable, nonatomic, retain) NSString *contextId;
@property (nullable, nonatomic, retain) NSString *routeId;
@property (nullable, nonatomic, retain) NSDate *apiTransmissionTimestamp;
@property (nullable, nonatomic, retain) NSNumber *apiTransmissionSuccess;
@property (nullable, nonatomic, retain) NSString *languageCode;
@property (nullable, nonatomic, retain) NSDate *recordedTimestamp;

@end

@interface GTFollowUpSubscription (CoreDataAccessors)

- (void)recordAPITransmissionSuccess:(NSNumber *)wasSuccessful atDatetime:(NSDate *)timestamp;

@end

NS_ASSUME_NONNULL_END
