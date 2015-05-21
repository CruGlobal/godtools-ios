//
//  GTUpdateTracker.m
//  godtools
//
//  Created by Michael Harrison on 5/15/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import "GTUpdateTracker.h"

@interface GTUpdateTracker ()

@property (strong, nonatomic) GTLanguage *language;
@property (strong, nonatomic) NSMutableArray *packagesWaitingForUpdate;
@property (strong, nonatomic) NSMutableArray *packagesFailedToUpdate;
@property (strong, nonatomic) NSMutableArray *packagesCompetedUpdate;

- (void)checkForCompletion;

@end

@implementation GTUpdateTracker

- (instancetype)init {
	
	self = [super init];
	if (self) {
		
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

- (void)updateInitiatedForLanguage:(GTLanguage *)language withPackages:(NSArray *)packages {
	
	self.packagesWaitingForUpdate = [packages mutableCopy];
	[self.packagesFailedToUpdate removeAllObjects];
	[self.packagesCompetedUpdate removeAllObjects];
	
	NSDictionary *userInfo = nil;
	if (self.language) {
		
		userInfo = @{GTDataImporterNotificationUpdateKeyLanguage: self.language};
		
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: GTDataImporterNotificationUpdateStarted
														object: self.owner
													  userInfo: userInfo];
}

- (void)updateCompletedForPackage:(GTPackage *)package {
	
	[self.packagesWaitingForUpdate removeObject:package];
	[self.packagesCompetedUpdate addObject:package];
	
	[self checkForCompletion];
}

- (void)updateFailedForPackage:(GTPackage *)package {
	
	[self.packagesWaitingForUpdate removeObject:package];
	[self.packagesCompetedUpdate addObject:package];
	
	[self checkForCompletion];
}

- (NSArray *)updateCancelled {
	
	NSDictionary *userInfo = nil;
	if (self.language) {
		
		userInfo = @{GTDataImporterNotificationUpdateKeyLanguage: self.language};
		
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: GTDataImporterNotificationUpdateCancelled
														object: self.owner
													  userInfo: userInfo];
	
	NSArray *packagesToCancel = [self.packagesWaitingForUpdate copy];
	
	[self.packagesWaitingForUpdate removeAllObjects];
	[self.packagesFailedToUpdate removeAllObjects];
	[self.packagesCompetedUpdate removeAllObjects];
	
	return packagesToCancel;
}

- (void)checkForCompletion {
	
	if (self.packagesWaitingForUpdate.count == 0) {
		
		NSDictionary *userInfo = nil;
		if (self.language) {
			
			userInfo = @{GTDataImporterNotificationUpdateKeyLanguage: self.language};
			
		}
		
		if (self.packagesCompetedUpdate.count == 0) {
				
			[[NSNotificationCenter defaultCenter] postNotificationName: GTDataImporterNotificationUpdateFailed
																object: self.owner
															  userInfo: userInfo];
			
		} else {
			
			[[NSNotificationCenter defaultCenter] postNotificationName: GTDataImporterNotificationUpdateFinished
																object: self.owner
															  userInfo: userInfo];
			
		}

	}
	
}

- (BOOL)hasFinishedUpdatingLanguage:(GTLanguage *)language {
	
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
