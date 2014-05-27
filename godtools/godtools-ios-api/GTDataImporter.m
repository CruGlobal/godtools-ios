//
//  GTDataImporter.m
//  godtools
//
//  Created by Michael Harrison on 3/18/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTDataImporter.h"

#import "RXMLElement.h"
#import "SSZipArchive.h"
#import "GTPackage+Helper.h"

NSString *const GTDataImporterNotificationLanguageDownloadProgressMade	= @"com.godtoolsapp.GTDataImporter.notifications.languageDownloadProgressMade";
NSString *const GTDataImporterNotificationLanguageDownloadFinished		= @"com.godtoolsapp.GTDataImporter.notifications.languageDownloadFinished";
NSString *const GTDataImporterNotificationLanguageDownloadPercentageKey	= @"com.godtoolsapp.GTDataImporter.notifications.languageDownloadProgressMade.key.percentage";

NSString *const GTDataImporterNotificationNameUpdateNeeded				= @"com.godtoolsapp.GTDataImporter.notifications.updateNeeded";
NSString *const GTDataImporterErrorDomain								= @"com.godtoolsapp.GTDataImporter.errorDomain";

NSInteger const GTDataImporterErrorCodeInvalidXml						= 1;

NSString *const GTDataImporterLanguageMetaXmlPathRelativeToRoot			= @"language";
NSString *const GTDataImporterLanguageMetaXmlAttributeNameCode			= @"code";
NSString *const GTDataImporterLanguageModelKeyNameCode					= @"code";

NSString *const GTDataImporterPackageMetaXmlPathRelativeToLanguage		= @"packages.package";
NSString *const GTDataImporterPackageMetaXmlAttributeNameCode			= @"code";
NSString *const GTDataImporterPackageMetaXmlAttributeNameIcon			= @"icon";
NSString *const GTDataImporterPackageMetaXmlAttributeNameName			= @"name";
NSString *const GTDataImporterPackageMetaXmlAttributeNameStatus			= @"status";
NSString *const GTDataImporterPackageMetaXmlAttributeNameType			= @"type";
NSString *const GTDataImporterPackageMetaXmlAttributeNameVersion		= @"version";
NSString *const GTDataImporterPackageModelKeyNameIdentifier				= @"identifier";

@interface GTDataImporter ()

@property (nonatomic, strong, readonly) GTAPI			*api;
@property (nonatomic, strong, readonly)	GTStorage		*storage;
@property (nonatomic, strong)			GTDefaults		*defaults;
@property (nonatomic, strong)			NSDate			*lastMenuInfoUpdate;
@property (nonatomic, strong)			NSMutableArray	*packagesNeedingToBeUpdated;

- (void)persistMenuInfoFromXMLElement:(RXMLElement *)rootElement;
- (void)fillArraysWithPackageAndLanguageCodesForXmlElement:(RXMLElement *)rootElement packageCodeArray:(NSMutableArray **)packageCodesArray languageCodeArray:(NSMutableArray **)languageCodesArray;
- (void)fillDictionariesWithPackageAndLanguageObjectsForPackageCodeArray:(NSArray *)packageCodes languageCodeArray:(NSArray *)languageCodes packageObjectsDictionary:(NSMutableDictionary **)packageObjectsDictionary languageObjectsDictionary:(NSMutableDictionary **)languageObjectsDictionary;
- (void)updateOrCreatePackageAndLanguageObjectsForXmlElement:(RXMLElement *)rootElement packageObjectsDictionary:(NSMutableDictionary *)packageObjectsDictionary languageObjectsDictionary:(NSMutableDictionary *)languageObjectsDictionary;
- (void)updateOrCreatePackageObjectsForXmlElement:(RXMLElement *)languageElement languageObject:(GTLanguage *)language packageObjectsDictionary:(NSMutableDictionary *)packageObjectsDictionary;

- (RXMLElement *)unzipResourcesAtTarget:(NSURL *)targetPath forLanguage:(GTLanguage *)language package:(GTPackage *)package;

- (void)displayMenuInfoRequestError:(NSError *)error;
- (void)displayMenuInfoImportError:(NSError *)error;
- (void)displayDownloadPackagesRequestError:(NSError *)error;
- (void)displayDownloadPackagesUnzippingError:(NSError *)error;

	
@end

@implementation GTDataImporter

#pragma mark - Initialization and Setup

+ (instancetype)sharedImporter {
	
    static GTDataImporter *_sharedImporter = nil;
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{
		
        _sharedImporter = [[GTDataImporter alloc] initWithAPI:[GTAPI sharedAPI]
													  storage:[GTStorage sharedStorage]
													 defaults:[GTDefaults sharedDefaults]];
		
    });
	
    return _sharedImporter;
}

- (instancetype)initWithAPI:(GTAPI *)api storage:(GTStorage *)storage defaults:(GTDefaults *)defaults {
	
	self = [self init];
	
    if (self) {
        
		self.packagesNeedingToBeUpdated	= [NSMutableArray array];
		
		_api		= api;
		_storage	= storage;
		_defaults	= defaults;
		
    }
	
    return self;
}

- (void)setDefaults:(GTDefaults *)defaults {
	
	[self willChangeValueForKey:@"defaults"];
	_defaults	= defaults;
	[self didChangeValueForKey:@"defaults"];
	
#warning incomplete implementation for setupForDefaults
	//add listeners
	//check if currentLanguage needs to be downloaded (ie first time app is opened)
	
}

#pragma mark - Menu Info Import

- (void)updateMenuInfo {
	
	__weak typeof(self)weakSelf = self;
	[self.api getMenuInfoSince:self.lastMenuInfoUpdate
					   success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLRootElement) {
						   
						   @try {
						   
							   [weakSelf persistMenuInfoFromXMLElement:XMLRootElement];
						   
						   } @catch (NSException *exception) {
							   
							   NSString *errorMessage	= NSLocalizedString(@"GTDataImporter_updateMenuInfo_bad_xml", @"Error message when meta endpoint response is missing data.");
							   NSError *xmlError = [NSError errorWithDomain:GTDataImporterErrorDomain
																	   code:GTDataImporterErrorCodeInvalidXml
																   userInfo:@{NSLocalizedDescriptionKey: errorMessage,
																			  NSLocalizedFailureReasonErrorKey: exception.description }];
							   [weakSelf displayMenuInfoImportError:xmlError];
							   
						   }
						   
					   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLRootElement) {
						   
						   [weakSelf displayMenuInfoRequestError:error];
						   
					   }];
	
}

- (void)persistMenuInfoFromXMLElement:(RXMLElement *)rootElement {
	
	if (rootElement) {
		
		NSMutableArray *packageCodes			= [NSMutableArray array];
		NSMutableArray *languageCodes			= [NSMutableArray array];
		
		//collect language and package codes for database fetch
		[self fillArraysWithPackageAndLanguageCodesForXmlElement:rootElement
												packageCodeArray:&packageCodes
											   languageCodeArray:&languageCodes];
		
		//fetch and prepare the available languages from the database
		NSMutableDictionary *packageObjects		= [NSMutableDictionary dictionary];
		NSMutableDictionary *languageObjects	= [NSMutableDictionary dictionary];
		
		[self fillDictionariesWithPackageAndLanguageObjectsForPackageCodeArray:packageCodes
															 languageCodeArray:languageCodes
													  packageObjectsDictionary:&packageObjects
													 languageObjectsDictionary:&languageObjects];
		
		//update models with XML data
		[self updateOrCreatePackageAndLanguageObjectsForXmlElement:rootElement
										  packageObjectsDictionary:packageObjects
										 languageObjectsDictionary:languageObjects];
		
		//save models to storage
		NSError *error;
		if (![self.storage.backgroundObjectContext save:&error]) {
			
			[self displayMenuInfoImportError:error];
			
		}
		
		//check for updates in current languages
		[self checkForPackagesWithNewVersionsForLanguage:nil];
		
	}
	
#warning untested implementation of persistMenuInfoFromXMLElement
	
}

- (void)fillArraysWithPackageAndLanguageCodesForXmlElement:(RXMLElement *)rootElement packageCodeArray:(NSMutableArray **)packageCodesArray languageCodeArray:(NSMutableArray **)languageCodesArray {
	
	NSMutableArray *packageCodes = *packageCodesArray;
	NSMutableArray *languageCodes = *languageCodesArray;
	
	//collect language and package codes for database fetch
	[rootElement iterate:GTDataImporterLanguageMetaXmlPathRelativeToRoot usingBlock:^(RXMLElement *languageElement) {
		
		NSString *languageCode = [languageElement attribute:GTDataImporterLanguageMetaXmlAttributeNameCode];
		[languageCodes addObject:languageCode];
		
		[languageElement iterate:GTDataImporterPackageMetaXmlPathRelativeToLanguage usingBlock:^(RXMLElement *packageElement) {
			
			NSString *packageCode	= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameCode];
			NSString *identifier	= [GTPackage identifierWithPackageCode:packageCode languageCode:languageCode];
			[packageCodes addObject:identifier];
			
		}];
		
	}];
	
#warning untested implementation of fillArraysWithPackageAndLanguageCodesForXmlElement
	
}

- (void)fillDictionariesWithPackageAndLanguageObjectsForPackageCodeArray:(NSArray *)packageCodes languageCodeArray:(NSArray *)languageCodes packageObjectsDictionary:(NSMutableDictionary **)packageObjectsDictionary languageObjectsDictionary:(NSMutableDictionary **)languageObjectsDictionary {
	
	NSMutableDictionary *packageObjects		= *packageObjectsDictionary;
	NSMutableDictionary *languageObjects	= *languageObjectsDictionary;
	
	NSArray *languageArray = [self.storage fetchArrayOfModels:[GTLanguage class]
													 usingKey:GTDataImporterLanguageModelKeyNameCode
													forValues:languageCodes
												 inBackground:YES];
	
	[languageArray enumerateObjectsUsingBlock:^(GTLanguage *language, NSUInteger index, BOOL *stop) {
		
		languageObjects[language.code]	= language;
		
	}];
	
	NSArray *packageArray = [self.storage fetchArrayOfModels:[GTPackage class]
													usingKey:GTDataImporterPackageModelKeyNameIdentifier
												   forValues:packageCodes
												inBackground:YES];
	
	[packageArray enumerateObjectsUsingBlock:^(GTPackage *package, NSUInteger index, BOOL *stop) {
		
		packageObjects[package.identifier]	= package;
		
	}];
	
#warning untested implementation of fillDictionariesWithPackageAndLanguageObjectsForPackageCodeArray
	
}

- (void)updateOrCreatePackageAndLanguageObjectsForXmlElement:(RXMLElement *)rootElement packageObjectsDictionary:(NSMutableDictionary *)packageObjectsDictionary languageObjectsDictionary:(NSMutableDictionary *)languageObjectsDictionary {
	
	NSMutableDictionary *packageObjects		= packageObjectsDictionary;
	NSMutableDictionary *languageObjects	= languageObjectsDictionary;
	
	[rootElement iterate:GTDataImporterLanguageMetaXmlPathRelativeToRoot usingBlock:^(RXMLElement *languageElement) {
		
		//update language
		NSString *languageCode		= [languageElement attribute:GTDataImporterLanguageMetaXmlAttributeNameCode];
		GTLanguage *language		= languageObjects[languageCode];
		
		if (!language) {
			
			language						= [GTLanguage languageWithCode:languageCode inContext:self.storage.backgroundObjectContext];
			languageObjects[languageCode]	= language;
			
		}
		
		[self updateOrCreatePackageObjectsForXmlElement:languageElement
										 languageObject:language
							   packageObjectsDictionary:packageObjects];
		
	}];
	
#warning untested implementation of updateOrCreatePackageAndLanguageObjectsForXmlElement
	
}

- (void)updateOrCreatePackageObjectsForXmlElement:(RXMLElement *)languageElement languageObject:(GTLanguage *)language packageObjectsDictionary:(NSMutableDictionary *)packageObjectsDictionary {
	
	NSMutableDictionary *packageObjects	= packageObjectsDictionary;
	NSString			*languageCode	= language.code;
	
	[languageElement iterate:GTDataImporterPackageMetaXmlPathRelativeToLanguage usingBlock:^(RXMLElement *packageElement) {
		
		//update package
		NSString *packageCode	= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameCode];
		NSString *identifier	= [GTPackage identifierWithPackageCode:packageCode languageCode:languageCode];
		NSNumber *version		= @([[packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameVersion] integerValue]);
		
		GTPackage *package		= packageObjects[identifier];
		
		if (!package) {
			
			package						= [GTPackage packageWithCode:packageCode language:language inContext:self.storage.backgroundObjectContext];
			packageObjects[identifier]	= package;
			
		}
		
		package.icon			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameIcon];
		package.name			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameName];
		package.status			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameStatus];
		package.type			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameType];
		package.latestVersion	= version;
		
		[packageObjects removeObjectForKey:identifier];
		
	}];
	
#warning untested implementation of updateOrCreatePackageObjectsForXmlElement
	
}

#pragma mark - Package downloading

- (void)downloadPackagesForLanguage:(GTLanguage *)language {
	
	NSParameterAssert(language);
	
	__weak typeof(self)weakSelf = self;
	[self.api getResourcesForLanguage:language
							 progress:^(NSNumber *percentage) {
								 
								 [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDownloadProgressMade
																					 object:weakSelf
																				   userInfo:@{GTDataImporterNotificationLanguageDownloadPercentageKey: percentage}];
								 
							 } success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath) {
								 
								 RXMLElement *contents = [weakSelf unzipResourcesAtTarget:targetPath forLanguage:language package:nil];
								 
#warning Need to update storage with data from contents.
#warning Post Notification that it is finished.
								 
							 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
								 
								 [weakSelf displayDownloadPackagesRequestError:error];
								 
							 }];
#warning untested implementation of downloadPackagesForLanguage
	
}

- (RXMLElement *)unzipResourcesAtTarget:(NSURL *)targetPath forLanguage:(GTLanguage *)language package:(GTPackage *)package {
	
	NSParameterAssert(language.code || package.code);
	
	NSString *temporaryFolderName	= [[NSUUID UUID] UUIDString];
	
	NSURL* documentDirectory		= [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
																		inDomain:NSUserDomainMask
															   appropriateForURL:nil
																		  create:YES
																		   error:nil];
	NSURL* temporaryDirectory		= [documentDirectory URLByAppendingPathComponent:temporaryFolderName isDirectory:YES];
	
	NSError *error;
	if(![SSZipArchive unzipFileAtPath:[targetPath absoluteString]
						toDestination:[temporaryDirectory absoluteString]
							overwrite:NO
							 password:nil
								error:&error
							 delegate:nil]) {
		
		[self displayDownloadPackagesUnzippingError:error];
		
	}
	
	RXMLElement *element = [RXMLElement elementFromXMLFile:[[temporaryDirectory URLByAppendingPathComponent:@"contents.xml"] absoluteString]];
	
#warning need to move all files to Documents Directory after contents.xml has been parsed.
#warning Need to update database with config filenames.
	
	return element;
	
}

#pragma mark - Package update checking and downloading

- (void)checkForPackagesWithNewVersionsForLanguage:(GTLanguage *)language {
	
	NSManagedObjectContext *context	= self.storage.backgroundObjectContext;
	NSArray *currentLanguages		= (language ? @[language.code] : @[self.defaults.currentLanguageCode, self.defaults.currentParallelLanguageCode]);
	NSFetchRequest *fetchRequest	= [[NSFetchRequest alloc] init];
	fetchRequest.entity				= [NSEntityDescription entityForName:NSStringFromClass([GTPackage class]) inManagedObjectContext:context];
	fetchRequest.predicate			= [NSPredicate predicateWithFormat:@"(localVersion < latestVersion) && language.code IN %@", currentLanguages];
	
	NSArray *fetchedObjects			= [context executeFetchRequest:fetchRequest error:nil];
	self.packagesNeedingToBeUpdated = [fetchedObjects mutableCopy];
	
	if (self.packagesNeedingToBeUpdated.count > 0) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationNameUpdateNeeded object:self];
		
	}
	
#warning untested implementation of checkForPackagesWithNewVersionsForLanguage
	
}

- (void)updatePackagesWithNewVersions {
	
#warning incomplete implementation for updatePackagesWithNewVersions
	
}

#pragma mark - Error Handling

- (void)displayMenuInfoRequestError:(NSError *)error {
	
	[self.api.errorHandler displayError:error];
	
}

- (void)displayMenuInfoImportError:(NSError *)error {
	
	[self.storage.errorHandler displayError:error];
	
}

- (void)displayDownloadPackagesUnzippingError:(NSError *)error {
	
	[self.storage.errorHandler displayError:error];
	
}

- (void)displayDownloadPackagesRequestError:(NSError *)error {
	
	[self.storage.errorHandler displayError:error];
	
}

@end
