//
//  GTDataImporterTests.m
//  godtools
//
//  Created by Michael Harrison on 3/21/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GTDataImporter.h"
#import "GTAPIStub.h"
#import "GTDefaults.h"

@interface GTDataImporterTests : XCTestCase

@property (nonatomic, strong) GTDataImporter *importer;
@property (nonatomic, strong) GTStorage *storage;

@end

@implementation GTDataImporterTests

- (void)setUp
{
    [super setUp];
	
	NSURL *documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
																	   inDomain:NSUserDomainMask
															  appropriateForURL:nil
																		 create:YES
																		  error:nil];
	NSURL *storeUrl = [documentsDirectory URLByAppendingPathComponent:@"godtools_data_importer_test.sqlite"];
	NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"GTModel" withExtension:@"momd"];
	
	self.storage = [[GTStorage alloc] initWithStoreURL:storeUrl
												   storeType:NSInMemoryStoreType
													modelURL:modelUrl
					 contextsSharePersistentStoreCoordinator:YES
												errorHandler:[GTStorageErrorHandler sharedErrorHandler]];
	
	GTAPIStub *api = [[GTAPIStub alloc] initWithConfig:[GTConfig sharedConfig]
										  errorHandler:[GTAPIErrorHandler sharedErrorHandler]];
	
	self.importer = [[GTDataImporter alloc] initWithAPI:api storage:self.storage packageExtractor:[GTPackageExtractor sharedPackageExtractor] defaults:[GTDefaults sharedDefaults]];
	
}

- (void)populateStorage {
	
	GTLanguage *english		= [self languageWithCode:@"en" name:@"English" downloaded:YES];
	[self addPackageToLanguage:english withCode:@"kgp" version:@"1.2"];			//	<package code="kgp" status="live" version="1.17"/>
	[self addPackageToLanguage:english withCode:@"fourlaws" version:@"0.1"];	//	<package code="fourlaws" status="live" version="1.6"/>
	[self addPackageToLanguage:english withCode:@"satisfied" version:@"1.15"];	//	<package code="satisfied" status="live" version="1.15"/>
	
	GTLanguage *thai		= [self languageWithCode:@"th" name:@"Thai" downloaded:NO];
	[self addPackageToLanguage:thai withCode:@"kgp" version:@"1.2"];			//	<package code="kgp" status="live" version="1.1"/>
	[self addPackageToLanguage:thai withCode:@"fourlaws" version:@"1.1"];		//	<package code="fourlaws" status="live" version="1.1"/>
	
	GTLanguage *spanish		= [self languageWithCode:@"es" name:@"Spanish" downloaded:NO];
	[self addPackageToLanguage:spanish withCode:@"kgp" version:@"1.1"];			//	<package code="kgp" status="live" version="1.1"/>
	[self addPackageToLanguage:spanish withCode:@"fourlaws" version:@"1.1"];	//	<package code="fourlaws" status="live" version="1.1"/>
	[self addPackageToLanguage:spanish withCode:@"satisfied" version:@"1.4"];	//	<package code="satisfied" status="live" version="1.4"/>
	
	GTLanguage *slovak		= [self languageWithCode:@"sk" name:@"Slovak" downloaded:YES];
	[self addPackageToLanguage:slovak withCode:@"kgp" version:@"2.0"];			//	<package code="kgp" status="live" version="1.1"/>
	
	[self languageWithCode:@"jn" name:@"Japanese" downloaded:NO];				//	empty language
	
	GTLanguage *ukrainian	= [self languageWithCode:@"uk" name:@"Ukrainian" downloaded:YES];
	[self addPackageToLanguage:ukrainian withCode:@"kgp" version:@"1.1"];		//	<package code="kgp" status="live" version="1.1"/>
	[self addPackageToLanguage:ukrainian withCode:@"fourlaws" version:@"1.0"];	//	<package code="fourlaws" status="live" version="1.1"/>
	
	[self.storage.mainObjectContext save:nil];
	
}

- (void)purgeStorage {
	
	NSFetchRequest * allPackages = [[NSFetchRequest alloc] init];
	[allPackages setEntity:[NSEntityDescription entityForName:@"GTPackage" inManagedObjectContext:self.storage.mainObjectContext]];
	[allPackages setIncludesPropertyValues:NO]; //only fetch the managedObjectID
	NSArray * packages = [self.storage.mainObjectContext executeFetchRequest:allPackages error:nil];
	
	__weak typeof(self)weakSelf = self;
	[packages enumerateObjectsUsingBlock:^(GTPackage *package, NSUInteger index, BOOL *stop) {
		[weakSelf.storage.mainObjectContext deleteObject:package];
	}];
	
	NSFetchRequest * allLanguages = [[NSFetchRequest alloc] init];
	[allLanguages setEntity:[NSEntityDescription entityForName:@"GTLanguage" inManagedObjectContext:self.storage.mainObjectContext]];
	[allLanguages setIncludesPropertyValues:NO]; //only fetch the managedObjectID
	NSArray * languages = [self.storage.mainObjectContext executeFetchRequest:allLanguages error:nil];
	
	[languages enumerateObjectsUsingBlock:^(GTPackage *language, NSUInteger index, BOOL *stop) {
		[weakSelf.storage.mainObjectContext deleteObject:language];
	}];
	
	[weakSelf.storage.mainObjectContext save:nil];
	
}

- (GTLanguage *)languageWithCode:(NSString *)code name:(NSString *)name downloaded:(BOOL)downloaded {
	
	GTLanguage *language	= [GTLanguage languageWithCode:code inContext:self.storage.mainObjectContext];
	language.name			= name;
	language.status			= @"live";
	language.downloaded		= @(downloaded);
	
	return language;
}

- (void)addPackageToLanguage:(GTLanguage *)language withCode:(NSString *)code version:(NSString *)version {
	
	GTPackage *package		= [GTPackage packageWithCode:code language:language inContext:self.storage.mainObjectContext];
	package.status			= @"live";
	
	if (version) {
		package.localVersion= version;
	}
	
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatTheDataImporterCanDetectNewUpdatesAvailable
{
	[self populateStorage];
	
	//Expectation
	XCTestExpectation *expectation = [self expectationWithDescription:@"New Updates Notification Not Triggered"];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:GTDataImporterNotificationNewVersionsAvailable
													  object:self
													   queue:nil
												  usingBlock:^(NSNotification *note) {
													  
													  NSNumber *numberOfUpdates = note.userInfo[GTDataImporterNotificationNewVersionsAvailableKeyNumberAvailable];
													  XCTAssertEqual(numberOfUpdates, @(3), @"wrong number of updates found");
													  [expectation fulfill];
												  }];
	
	[self.importer updateMenuInfo];
	
	[self waitForExpectationsWithTimeout:5.0 handler:nil];
	
	
}

@end
