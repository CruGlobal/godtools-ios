//
//  GTDataImporter.m
//  godtools
//
//  Created by Michael Harrison on 3/18/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTDataImporter.h"

#import "RXMLElement.h"
#import "GTPackage+Helper.h"

NSString *const GTDataImporterNotificationNameUpdateNeeded			= @"com.godtoolsapp.GTDataImporter.notifications.updateNeeded";

NSString *const GTDataImporterLanguageMetaXmlPathRelativeToRoot		= @"language";
NSString *const GTDataImporterLanguageMetaXmlAttributeNameCode		= @"code";
NSString *const GTDataImporterLanguageModelKeyNameCode				= @"code";

NSString *const GTDataImporterPackageMetaXmlPathRelativeToLanguage	= @"packages.package";
NSString *const GTDataImporterPackageMetaXmlAttributeNameCode		= @"code";
NSString *const GTDataImporterPackageMetaXmlAttributeNameIcon		= @"icon";
NSString *const GTDataImporterPackageMetaXmlAttributeNameName		= @"name";
NSString *const GTDataImporterPackageMetaXmlAttributeNameStatus		= @"status";
NSString *const GTDataImporterPackageMetaXmlAttributeNameType		= @"type";
NSString *const GTDataImporterPackageMetaXmlAttributeNameVersion	= @"version";
NSString *const GTDataImporterPackageModelKeyNameIdentifier			= @"identifier";

@interface GTDataImporter ()

@property (nonatomic, strong, readonly) GTAPI			*api;
@property (nonatomic, strong, readonly)	GTStorage		*storage;
@property (nonatomic, strong, readonly) GTDefaults		*defaults;
@property (nonatomic, strong)			NSDate			*lastMenuInfoUpdate;
@property (nonatomic, strong)			NSMutableArray	*packagesNeedingToBeUpdated;

- (void)setupForDefaults;

- (void)persistMenuInfoFromXMLElement:(RXMLElement *)rootElement;
- (void)displayMenuInfoRequestError:(NSError *)error;

- (void)cleanUpMenuImportFailureWithError:(NSError *)error;
- (void)fireMenuImportSuccessNotifications;

- (void)fillArraysWithPackageAndLanguageCodesForXmlElement:(RXMLElement *)rootElement packageCodeArray:(NSMutableArray **)packageCodesArray languageCodeArray:(NSMutableArray **)languageCodesArray;
- (void)fillDictionariesWithPackageAndLanguageObjectsForPackageCodeArray:(NSArray *)packageCodes languageCodeArray:(NSArray *)languageCodes packageObjectsDictionary:(NSMutableDictionary **)packageObjectsDictionary languageObjectsDictionary:(NSMutableDictionary **)languageObjectsDictionary;
- (void)updateOrCreatePackageAndLanguageObjectsForXmlElement:(RXMLElement *)rootElement packageObjectsDictionary:(NSMutableDictionary *)packageObjectsDictionary languageObjectsDictionary:(NSMutableDictionary *)languageObjectsDictionary;
- (void)updateOrCreatePackageObjectsForXmlElement:(RXMLElement *)languageElement languageObject:(GTLanguage *)language packageObjectsDictionary:(NSMutableDictionary *)packageObjectsDictionary;
- (void)checkForUpdateAndRegisterPackage:(GTPackage *)package basedOnLanguageCode:(NSString *)languageCode newVersionNumber:(NSNumber *)newVersionNumber;
	
@end

@implementation GTDataImporter

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
		
		if (self.defaults) {
			
			[self setupForDefaults];
			
		}
		
    }
	
    return self;
}

- (void)setupForDefaults {
	
#warning incomplete implementation for setupForDefaults
	//add listeners
	//check if currentLanguage needs to be downloaded (ie first time app is opened)
	
}

- (void)updateMenuInfo {
	
	__weak typeof(self)weakSelf = self;
	[self.api getMenuInfoSince:self.lastMenuInfoUpdate
					   success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLRootElement) {
						   
						   [weakSelf persistMenuInfoFromXMLElement:XMLRootElement];
						   
					   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLRootElement) {
						   
						   [weakSelf displayMenuInfoRequestError:error];
						   
					   }];
	
}

- (void)updatePackagesWithNewVersions {
	
	#warning incomplete implementation for updatePackagesWithNewVersions
	
}

- (void)downloadPackagesForLanguage:(GTLanguage *)language {
	
	#warning incomplete implementation for downloadPackagesForLanguage
	
}

- (void)checkForPackagesWithNewVersionsForLanguage:(GTLanguage *)language {
	
	#warning incomplete implementation for checkForPackagesWithNewVersionsForLanguage
	
}

- (void)updatePackagesWithNewVersionsForLanguage:(GTLanguage *)langauge {
	
	#warning incomplete implementation for updatePackagesWithNewVersionsForLanguage
	
}

- (void)persistMenuInfoFromXMLElement:(RXMLElement *)rootElement {
	
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
	if ([self.storage.backgroundObjectContext save:&error]) {
		
		[self fireMenuImportSuccessNotifications];
		
	} else {
		
		[self cleanUpMenuImportFailureWithError:error];
		
	}
	
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
			
		} else {
			
			[self checkForUpdateAndRegisterPackage:package basedOnLanguageCode:languageCode newVersionNumber:version];
			
		}
		
		package.icon			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameIcon];
		package.name			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameName];
		package.status			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameStatus];
		package.type			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameType];
		package.version			= version;
		
		[packageObjects removeObjectForKey:identifier];
		
	}];
	
}

- (void)checkForUpdateAndRegisterPackage:(GTPackage *)package basedOnLanguageCode:(NSString *)languageCode newVersionNumber:(NSNumber *)newVersionNumber {
	
	if ([self.defaults.currentLanguageCode isEqualToString:languageCode] ||
		[self.defaults.currentParallelLanguageCode isEqualToString:languageCode] ||
		[package.version integerValue] < [newVersionNumber integerValue]) {
		
		[self.packagesNeedingToBeUpdated addObject:package];
		
	}
	
}

- (void)displayMenuInfoRequestError:(NSError *)error {
	
	[self.api.errorHandler displayError:error];
	
}

- (void)fireMenuImportSuccessNotifications {
	
	if (self.packagesNeedingToBeUpdated.count > 0) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationNameUpdateNeeded object:self];
		
	}
	
}

- (void)cleanUpMenuImportFailureWithError:(NSError *)error {
	
	[self.storage.errorHandler displayError:error];
	
#warning make conditional if there is an error that can be recovered from
	[self.packagesNeedingToBeUpdated removeAllObjects];
	
}



@end
