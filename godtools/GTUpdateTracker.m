//
//  GTUpdateTracker.m
//  godtools
//
//  Created by Michael Harrison on 5/15/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import "GTUpdateTracker.h"
#import "GTGoogleAnalyticsTracker.h"

@interface GTUpdateTracker ()

@property (strong, nonatomic) GTLanguage *language;
@property (strong, nonatomic) NSMutableArray *languagesWaitingForUpdate;
@property (strong, nonatomic) NSMutableArray *languagesFailedToUpdate;
@property (strong, nonatomic) NSMutableArray *languagesCompetedUpdate;
@property (strong, nonatomic) NSMutableArray *packagesWaitingForUpdate;
@property (strong, nonatomic) NSMutableArray *packagesFailedToUpdate;
@property (strong, nonatomic) NSMutableArray *packagesCompetedUpdate;

- (void)checkForCompletion;

@end

@implementation GTUpdateTracker

- (instancetype)init {
	
	self = [super init];
	if (self) {
		
		self.languagesWaitingForUpdate	= [NSMutableArray array];
		self.languagesFailedToUpdate	= [NSMutableArray array];
		self.languagesCompetedUpdate	= [NSMutableArray array];
		
		self.packagesWaitingForUpdate	= [NSMutableArray array];
		self.packagesFailedToUpdate		= [NSMutableArray array];
		self.packagesCompetedUpdate		= [NSMutableArray array];
		
	}
	return self;
}

+ (instancetype)updateTrackerWithNotificationOwner:(id)owner {
	
	GTUpdateTracker *updateTracker	= [[self alloc] init];
	updateTracker.owner				= owner;
	
	return updateTracker;
}

- (void)updateInitiatedForLanguage:(GTLanguage *)language withMajorUpdates:(NSArray *)majorUpdates minorUpdates:(NSArray *)minorUpdates {
	
	self.languagesWaitingForUpdate = [majorUpdates mutableCopy];
	[self.languagesFailedToUpdate removeAllObjects];
	[self.languagesCompetedUpdate removeAllObjects];
	
	self.packagesWaitingForUpdate = [minorUpdates mutableCopy];
	[self.packagesFailedToUpdate removeAllObjects];
	[self.packagesCompetedUpdate removeAllObjects];
	
	NSDictionary *userInfo = nil;
	if (self.language) {
		
		userInfo = @{GTDataImporterNotificationUpdateKeyLanguage: self.language};
		
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: GTDataImporterNotificationUpdateStarted
														object: self.owner
													  userInfo: userInfo];
	
	[[GTGoogleAnalyticsTracker sharedInstance] sendEventWithCategory:@"update"
															  action:@"started"
															   label:@"number-of-packages"
															   value:@(majorUpdates.count + minorUpdates.count)];
}

- (void)minorUpdateCompletedForPackage:(GTPackage *)package {
	
	[self.packagesWaitingForUpdate removeObject:package];
	[self.packagesCompetedUpdate addObject:package];
	
	[self checkForCompletion];
}

- (void)minorUpdateFailedForPackage:(GTPackage *)package {
	
	[self.packagesWaitingForUpdate removeObject:package];
	[self.packagesFailedToUpdate addObject:package];
	
	[[GTGoogleAnalyticsTracker sharedInstance] sendEventWithCategory:@"update"
															  action:@"failed"
															   label:package.identifier
															   value:@(1)];
	
	[self checkForCompletion];
}

- (void)majorUpdateCompletedForLanguage:(GTLanguage *)language {
	
	[self.languagesWaitingForUpdate removeObject:language];
	[self.languagesCompetedUpdate addObject:language];
	
	[self checkForCompletion];
}

- (void)majorUpdateFailedForLanguage:(GTLanguage *)language {
	
	[self.languagesWaitingForUpdate removeObject:language];
	[self.languagesFailedToUpdate addObject:language];
	
	[[GTGoogleAnalyticsTracker sharedInstance] sendEventWithCategory:@"update"
															  action:@"failed"
															   label:language.code
															   value:@(1)];
	
	[self checkForCompletion];
}

- (NSArray *)updateCancelledForLanguage:(GTLanguage *)language {
	
	NSPredicate *predicate							= [NSPredicate predicateWithFormat:@"language.code == %@", language.code];
	NSArray *packagesForLanguageWaitingForUpdate	= [self.packagesWaitingForUpdate filteredArrayUsingPredicate:predicate];
	
	if (packagesForLanguageWaitingForUpdate.count) {
		[self.packagesWaitingForUpdate removeObjectsInArray:packagesForLanguageWaitingForUpdate];
		[self.packagesFailedToUpdate addObjectsFromArray:packagesForLanguageWaitingForUpdate];
	}
	
	NSInteger numberOfUpdates = packagesForLanguageWaitingForUpdate.count ?: 0;
	NSInteger numberOfLanguages = self.languagesWaitingForUpdate.count;
	[self.languagesWaitingForUpdate removeObject:language];
	if (numberOfLanguages > self.languagesWaitingForUpdate.count) {
		
		[self.languagesFailedToUpdate addObject:language];
		numberOfUpdates++;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: GTDataImporterNotificationUpdateCancelledForLanguage
														object: self.owner
													  userInfo: @{GTDataImporterNotificationUpdateKeyLanguage: language}];
	
	[[GTGoogleAnalyticsTracker sharedInstance] sendEventWithCategory:@"update"
															  action:@"cancelled"
															   label:@"number-of-updates"
															   value:@(numberOfUpdates)];
	
	return packagesForLanguageWaitingForUpdate;
}

- (NSArray *)updateCancelled {
	
	NSDictionary *userInfo = nil;
	if (self.language) {
		
		userInfo = @{GTDataImporterNotificationUpdateKeyLanguage: self.language};
		
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: GTDataImporterNotificationUpdateCancelled
														object: self.owner
													  userInfo: userInfo];
	
	NSArray *packagesToCancel = [self.packagesWaitingForUpdate arrayByAddingObjectsFromArray:self.languagesWaitingForUpdate];
	
	[[GTGoogleAnalyticsTracker sharedInstance] sendEventWithCategory:@"update"
															  action:@"cancelled"
															   label:@"number-of-updates"
															   value:@(packagesToCancel.count)];
	
	[self.languagesWaitingForUpdate removeAllObjects];
	[self.languagesFailedToUpdate removeAllObjects];
	[self.languagesCompetedUpdate removeAllObjects];
	[self.packagesWaitingForUpdate removeAllObjects];
	[self.packagesFailedToUpdate removeAllObjects];
	[self.packagesCompetedUpdate removeAllObjects];
	
	return packagesToCancel;
}

- (void)checkForCompletion {
	
	if (self.languagesWaitingForUpdate.count == 0 && self.packagesWaitingForUpdate.count == 0) {
		
		NSDictionary *userInfo = nil;
		if (self.language) {
			
			userInfo = @{GTDataImporterNotificationUpdateKeyLanguage: self.language};
			
		}
		
		if (self.languagesCompetedUpdate == 0 && self.packagesCompetedUpdate.count == 0) {
				
			[[NSNotificationCenter defaultCenter] postNotificationName: GTDataImporterNotificationUpdateFailed
																object: self.owner
															  userInfo: userInfo];
			
			[[GTGoogleAnalyticsTracker sharedInstance] sendEventWithCategory:@"update"
																	  action:@"failed-completely"
																	   label:@"number-of-updates"
																	   value:@(self.languagesFailedToUpdate.count + self.packagesFailedToUpdate.count)];
			
		} else {
			
			[[NSNotificationCenter defaultCenter] postNotificationName: GTDataImporterNotificationUpdateFinished
																object: self.owner
															  userInfo: userInfo];
			
			[[GTGoogleAnalyticsTracker sharedInstance] sendEventWithCategory:@"update"
																	  action:@"finished"
																	   label:@"number-of-updates"
																	   value:@(self.languagesCompetedUpdate.count + self.packagesCompetedUpdate.count)];
			
		}

	}
	
}

- (BOOL)hasFinishedUpdatingLanguage:(GTLanguage *)language {
	
	if (!language.hasUpdates) {
		return YES;
	}
	
	NSPredicate *predicate							= [NSPredicate predicateWithFormat:@"language.code == %@", language.code];
	NSArray *packagesForLanguageWaitingForUpdate	= [self.packagesWaitingForUpdate filteredArrayUsingPredicate:predicate];
	NSArray *packagesForLanguageThatFailedUpdate	= [self.packagesFailedToUpdate filteredArrayUsingPredicate:predicate];
	
	if (packagesForLanguageWaitingForUpdate.count > 0 || packagesForLanguageThatFailedUpdate.count > 0) {
		return NO;
	} else {
		return YES;
	}
	
}

@end
