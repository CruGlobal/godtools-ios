//
//  GTDataImporter.m
//  godtools
//
//  Created by Michael Harrison on 3/18/14.
//  Modified by Lee Braddock.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTDataImporter.h"

#import "RXMLElement.h"
#import "GTPackage.h"
#import <GTViewController/GTFileLoader.h>
#import "GTUpdateTracker.h"

NSString *const GTDataImporterErrorDomain								= @"com.godtoolsapp.GTDataImporter.errorDomain";

NSInteger const GTDataImporterErrorCodeInvalidXml						= 1;
NSInteger const GTDataImporterErrorCodeInvalidZip                       = 2;
NSInteger const GTDataImporterErrorCodeCouldNotSave						= 3;

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
BOOL gtLanguageDownloadUserCancellation                                 = FALSE;
BOOL gtUpdatePackagesUserCancellation									= FALSE;

@interface GTDataImporter ()

@property (nonatomic, strong, readonly) GTAPI				*api;
@property (nonatomic, strong, readonly)	GTStorage			*storage;
@property (nonatomic, strong, readonly) GTPackageExtractor	*packageExtractor;
@property (nonatomic, strong)			GTDefaults			*defaults;
@property (nonatomic, strong)			NSDate				*lastMenuInfoUpdate;
@property (nonatomic, strong)			NSMutableArray		*packagesNeedingMajorUpdate;
@property (nonatomic, strong)			NSMutableArray		*packagesNeedingMinorUpdate;
@property (nonatomic, strong)			GTUpdateTracker		*updateTracker;

- (void)fillArraysWithPackageAndLanguageCodesForXmlElement:(RXMLElement *)rootElement packageCodeArray:(NSMutableArray **)packageCodesArray languageCodeArray:(NSMutableArray **)languageCodesArray;
- (void)fillDictionariesWithPackageAndLanguageObjectsForPackageCodeArray:(NSArray *)packageCodes languageCodeArray:(NSArray *)languageCodes packageObjectsDictionary:(NSMutableDictionary **)packageObjectsDictionary languageObjectsDictionary:(NSMutableDictionary **)languageObjectsDictionary;
- (void)updateOrCreatePackageAndLanguageObjectsForXmlElement:(RXMLElement *)rootElement packageObjectsDictionary:(NSMutableDictionary *)packageObjectsDictionary languageObjectsDictionary:(NSMutableDictionary *)languageObjectsDictionary;
- (void)updateOrCreatePackageObjectsForXmlElement:(RXMLElement *)languageElement languageObject:(GTLanguage *)language packageObjectsDictionary:(NSMutableDictionary *)packageObjectsDictionary;

- (void)displayMenuInfoRequestError:(NSError *)error;
- (void)displayMenuInfoImportError:(NSError *)error;
- (void)displayPackageImportError:(NSError *)error;
- (void)displayDownloadPackagesRequestError:(NSError *)error;

- (void)cleanUpAfterDownloadingPackage:(GTPackage *)package;
- (void)addUpdateTrackingCallbacks;
- (void)downloadPackage:(GTPackage *)package;
- (void)downloadPackage:(GTPackage *)package withProgressNotifier:(NSString *) progressNotificationName withSuccessNotifier:(NSString *) successNotificationName withFailureNotifier:(NSString *) failureNotificationName;

@end

@implementation GTDataImporter

#pragma mark - Initialization and Setup

+ (instancetype)sharedImporter {
	
    static GTDataImporter *_sharedImporter = nil;
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{
		
        _sharedImporter = [[GTDataImporter alloc] initWithAPI:[GTAPI sharedAPI]
													  storage:[GTStorage sharedStorage]
											 packageExtractor:[GTPackageExtractor sharedPackageExtractor]
													 defaults:[GTDefaults sharedDefaults]];
		
    });
	
    return _sharedImporter;
}

- (instancetype)initWithAPI:(GTAPI *)api storage:(GTStorage *)storage packageExtractor:(GTPackageExtractor *)packageExtractor defaults:(GTDefaults *)defaults {
	
	self = [self init];
	
    if (self) {
        
		self.packagesNeedingMajorUpdate	= [NSMutableArray array];
		self.packagesNeedingMinorUpdate	= [NSMutableArray array];
		
		self.updateTracker				= [GTUpdateTracker updateTrackerWithNotificationOwner:self];
		[self addUpdateTrackingCallbacks];
		
		_api				= api;
		_storage			= storage;
		_defaults			= defaults;
		_packageExtractor	= packageExtractor;
		
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationMenuUpdateStarted
                                                        object:weakSelf
                                                      userInfo:nil];

	[self.api getMenuInfoSince:self.lastMenuInfoUpdate
					   success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLRootElement) {
						   
						   @try {

							   [weakSelf importMenuInfoFromXMLElement:XMLRootElement];
                               
                               [[NSNotificationCenter defaultCenter]
                                    postNotificationName:GTDataImporterNotificationMenuUpdateFinished
                                    object:weakSelf
                                    userInfo:nil];
						   
						   } @catch (NSException *exception) {

							   NSString *errorMessage	= NSLocalizedString(@"menu_download_bad_xml", nil);
							   NSError *xmlError = [NSError errorWithDomain:GTDataImporterErrorDomain
																	   code:GTDataImporterErrorCodeInvalidXml
																   userInfo:@{NSLocalizedDescriptionKey: errorMessage,
																			  NSLocalizedFailureReasonErrorKey: exception.description }];
							   [weakSelf displayMenuInfoImportError:xmlError];

                               [[NSNotificationCenter defaultCenter]
                                    postNotificationName:GTDataImporterNotificationMenuUpdateFinished
                                    object:weakSelf
                                    userInfo:nil];
						   }
						   
					   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, RXMLElement *XMLRootElement) {
						   
						   [weakSelf displayMenuInfoRequestError:error];
                           [[NSNotificationCenter defaultCenter]
                                postNotificationName:GTDataImporterNotificationMenuUpdateFinished
                                object:weakSelf
                                userInfo:nil];
                           
					   }];

	
}

- (BOOL)importMenuInfoFromXMLElement:(RXMLElement *)rootElement {

	BOOL storageError = NO;
	
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
			
			storageError = YES;
			[self displayMenuInfoImportError:error];
			
        }
		
		[self checkForPackagesWithNewVersionsForLanguageCodes:nil];
		
		return !storageError;
	}
	
	return NO;
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
            language.name                   = [languageElement attribute:@"name"];
			languageObjects[languageCode]	= language;
            //NSLog(@"Language %@ created",language.name);
        }else{
            //NSLog(@"got %@ with %i packages",language.name, language.packages.count);
        }
		[self updateOrCreatePackageObjectsForXmlElement:languageElement
										 languageObject:language
							   packageObjectsDictionary:packageObjects];
		
	}];
	
}

- (void)updateOrCreatePackageObjectsForXmlElement:(RXMLElement *)languageElement languageObject:(GTLanguage *)language packageObjectsDictionary:(NSMutableDictionary *)packageObjectsDictionary {
	
	NSMutableDictionary *packageObjects	= packageObjectsDictionary;
	NSString			*languageCode	= language.code;

    if([[[languageElement child:@"packages"] children:@"package"] count] > 0){
		
        [languageElement iterate:GTDataImporterPackageMetaXmlPathRelativeToLanguage usingBlock:^(RXMLElement *packageElement) {
			
            //update package
            NSString *packageCode	= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameCode];
            NSString *identifier	= [GTPackage identifierWithPackageCode:packageCode languageCode:languageCode];
            NSString *version		= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameVersion];
            GTPackage *package		= packageObjects[identifier];

            if (!package) {
				
                package						= [GTPackage packageWithCode:packageCode language:language inContext:self.storage.backgroundObjectContext];
                packageObjects[identifier]	= package;
                
            }else{
				
                if(![package.status isEqualToString:[packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameStatus]]){
					
                    package						= [GTPackage packageWithCode:packageCode language:language inContext:self.storage.backgroundObjectContext];
                    packageObjects[identifier]	= package;
					
                }else{
					
                }
            }
            
            if([packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameIcon]){
                package.icon			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameIcon];
            }
            
            if([packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameName]){
                package.name			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameName];
            }

            package.status			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameStatus];
            package.type			= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameType];
			//package.localVersion	= package.localVersion; //don't change local version. The xml data only represents what is on the server
			[package setIfGreaterThanLatestVersion:version];
			
            [packageObjects removeObjectForKey:identifier];
            
        }];
    }
	
}

#pragma mark - Package downloading

- (void)downloadXmlFilesForPackage:(GTPackage *)package {
	NSLog(@"downloadXmlFilesForPackage() ...");
	[self downloadXmlFilesForPackage:package withProgressNotifier:GTDataImporterNotificationPackageXmlDownloadProgressMade withSuccessNotifier:GTDataImporterNotificationPackageXmlDownloadFinished withFailureNotifier:GTDataImporterNotificationPackageXmlDownloadFailed];
}

- (void)downloadPackage:(GTPackage *)package {
	NSLog(@"downloadPackage() ...");
	[self downloadPackage:package withProgressNotifier:GTDataImporterNotificationPackageDownloadProgressMade withSuccessNotifier:GTDataImporterNotificationPackageDownloadFinished withFailureNotifier:GTDataImporterNotificationPackageDownloadFailed];
}

- (void)downloadPackagesForLanguage:(GTLanguage *)language {
    NSLog(@"downloadPackagesForLanguage() ...");
     [self downloadPackagesForLanguage:language withProgressNotifier:GTDataImporterNotificationLanguageDownloadProgressMade withSuccessNotifier:GTDataImporterNotificationLanguageDownloadFinished withFailureNotifier:GTDataImporterNotificationLanguageDownloadFinished];
}

- (void)downloadXmlFilesForPackage:(GTPackage *)package withProgressNotifier:(NSString *) progressNotificationName withSuccessNotifier:(NSString *) successNotificationName withFailureNotifier:(NSString *) failureNotificationName {
	
	NSParameterAssert(package);
	
	__weak typeof(self)weakSelf = self;
	[self.api getXmlFilesForPackage:package
						   progress:^(NSNumber *percentage) {
								
								[[NSNotificationCenter defaultCenter] postNotificationName:progressNotificationName
																					object:weakSelf
																				  userInfo:@{GTDataImporterNotificationLanguageDownloadPercentageKey: percentage,
																							 GTDataImporterNotificationPackageKeyPackage: package}];
								
							} success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath) {
								
								RXMLElement *contents =[weakSelf.packageExtractor unzipResourcesAtTarget:targetPath forLanguage:package.language package:package];
								
								if(contents!=nil){
									//Update storage with data from contents.
									[contents iterate:@"resource" usingBlock: ^(RXMLElement *resource) {
										
										package.name			= [NSString stringWithUTF8String:[[resource attribute:@"name"] UTF8String]];
										package.configFile		= [resource attribute:@"config"];
										package.icon			= [resource attribute:@"icon"];
										package.status			= [resource attribute:@"status"];
										package.localVersion	= [resource attribute:@"version"];
										package.latestVersion	= [resource attribute:@"version"];
										
									}];
									
									[[NSNotificationCenter defaultCenter] postNotificationName:successNotificationName
																						object:self
																					  userInfo:@{GTDataImporterNotificationPackageKeyPackage: package}];
									
									[weakSelf cleanUpAfterDownloadingPackage:package];
								}
								
							} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
								
								if (!gtUpdatePackagesUserCancellation) {
									
									[weakSelf displayDownloadPackagesRequestError:error];
									
								}
								
								gtUpdatePackagesUserCancellation = FALSE;
								[[NSNotificationCenter defaultCenter] postNotificationName:failureNotificationName
																					object:self
																				  userInfo:@{GTDataImporterNotificationPackageKeyPackage: package}];
								
							}];
	
}

- (void)downloadPackage:(GTPackage *)package withProgressNotifier:(NSString *) progressNotificationName withSuccessNotifier:(NSString *) successNotificationName withFailureNotifier:(NSString *) failureNotificationName {
	
	NSLog(@"downloadPackagesForLanguageForImporter() ...");
	
	NSParameterAssert(package);
	NSLog(@"will download %@",package.name);
	__weak typeof(self)weakSelf = self;
	[self.api getResourcesForPackage:package
							 progress:^(NSNumber *percentage) {
								 
								 NSLog(@"progress ...");
								 [[NSNotificationCenter defaultCenter] postNotificationName:progressNotificationName
																					 object:weakSelf
																				   userInfo:@{GTDataImporterNotificationLanguageDownloadPercentageKey: percentage,
																							  GTDataImporterNotificationPackageKeyPackage: package}];
								 
							 } success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath) {
								 
								 RXMLElement *contents =[weakSelf.packageExtractor unzipResourcesAtTarget:targetPath forLanguage:package.language package:package];
								 
								 if(contents!=nil){
									 //Update storage with data from contents.
									 [contents iterate:@"resource" usingBlock: ^(RXMLElement *resource) {
										 
										 package.name = [NSString stringWithUTF8String:[[resource attribute:@"name"] UTF8String]];
										 NSLog(@"name: %@",package.name);
										 package.configFile = [resource attribute:@"config"];
										 package.icon = [resource attribute:@"icon"];
										 package.status = [resource attribute:@"status"];
										 package.localVersion = [resource attribute:@"version"];
										 package.latestVersion = [resource attribute:@"version"];
										 
									 }];
									 
									 [[NSNotificationCenter defaultCenter] postNotificationName:successNotificationName
																						 object:self
																					   userInfo:@{GTDataImporterNotificationPackageKeyPackage:package}];
									 
									 [weakSelf cleanUpAfterDownloadingPackage:package];
								 }
								 
							 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
								 if(!gtUpdatePackagesUserCancellation) {
									 [weakSelf displayDownloadPackagesRequestError:error];
								 }
								 gtUpdatePackagesUserCancellation = FALSE;
								 [[NSNotificationCenter defaultCenter] postNotificationName:failureNotificationName
																					 object:self
																				   userInfo:@{GTDataImporterNotificationPackageKeyPackage: package}];
							 }];
	
}

- (void)downloadPackagesForLanguage:(GTLanguage *)language withProgressNotifier:(NSString *) progressNotificationName withSuccessNotifier:(NSString *) successNotificationName withFailureNotifier:(NSString *) failureNotificationName {
    NSLog(@"downloadPackagesForLanguageForImporter() ...");

   	NSParameterAssert(language);
    NSLog(@"will download %@",language.name);
	__weak typeof(self)weakSelf = self;
	[self.api getResourcesForLanguage:language
							 progress:^(NSNumber *percentage) {
                                 NSLog(@"progress ...");
                                     [[NSNotificationCenter defaultCenter] postNotificationName:progressNotificationName
                                                                                         object:weakSelf
                                                                                       userInfo:@{GTDataImporterNotificationLanguageDownloadPercentageKey: percentage}];
							 } success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath) {
                                 if(response.statusCode == 200){
									 
                                     RXMLElement *contents =[weakSelf.packageExtractor unzipResourcesAtTarget:targetPath forLanguage:language package:nil];
									 
									 if ([self importPackageContentsFromElement:contents forLanguage:language]) {
										 
										 if([GTDefaults sharedDefaults].isChoosingForMainLanguage){
											 
											 if([[[GTDefaults sharedDefaults]currentParallelLanguageCode] isEqualToString:language.code]){
												 //[[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:[[GTDefaults sharedDefaults] currentLanguageCode]];
												 [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:nil];
											 }
											 
											 
											 [[GTDefaults sharedDefaults]setCurrentLanguageCode:language.code];
											 
										 }else{
											 NSLog(@"set %@ as parallel",language.name );
											 [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:language.code];
										 }
									 } else {
										 
										 NSError *error = [NSError errorWithDomain:GTDataImporterErrorDomain
																			  code:GTDataImporterErrorCodeCouldNotSave
																		  userInfo:nil];
										 [self displayPackageImportError:error];
										 
									 }
									 
									 [[GTDefaults sharedDefaults] setTranslationDownloadStatus:@"finished"];
									 
                                 }else if(response.statusCode == 500){
                                    NSString *errorMessage	= NSLocalizedString(@"packages_download_error", nil);
                                     NSError *error = [NSError errorWithDomain:GTDataImporterErrorDomain
                                                                             code:GTDataImporterErrorCodeInvalidXml
                                                                         userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
                                     if(language.downloaded == [NSNumber numberWithBool:NO]){
                                         [weakSelf displayDownloadPackagesRequestError:error];
                                     }
                                 }
                                 if([[GTDefaults sharedDefaults] isInTranslatorMode] == [NSNumber numberWithBool:YES]){
                                     [self downloadDraftsForLanguage:language];
                                 }else{
                                     [[NSNotificationCenter defaultCenter] postNotificationName:successNotificationName object:self];
                                 }
							 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                 if(!gtLanguageDownloadUserCancellation) {
                                     [weakSelf displayDownloadPackagesRequestError:error];
                                 }
                                 gtLanguageDownloadUserCancellation = FALSE;
                                 [[NSNotificationCenter defaultCenter] postNotificationName:failureNotificationName object:self];
							 }];

	
}

- (void)cancelDownloadPackagesForLanguage {
    gtLanguageDownloadUserCancellation = TRUE;
    [self.api cancelGetResourcesForLanguage];
}

- (void)cancelUpdatePackages {
	gtUpdatePackagesUserCancellation = TRUE;
	[self.api cancelGetResourcesForPackage];
}


#pragma mark - Import Package into Database

- (BOOL)importPackageContentsFromElement:(RXMLElement *)contents forLanguage:(GTLanguage *)language {
	
	if(contents!=nil){
		//Update storage with data from contents.
		[language removePackages:language.packages];
		[contents iterate:@"resource" usingBlock: ^(RXMLElement *resource) {
			
			NSString *existingIdentifier = [GTPackage identifierWithPackageCode:[resource attribute:@"package"] languageCode:language.code];
			
			GTPackage *package;
			
			NSArray *packageArray = [self.storage fetchArrayOfModels:[GTPackage class] usingKey:@"identifier" forValues:@[existingIdentifier] inBackground:YES];
			
			if([packageArray count]==0){
				package = [GTPackage packageWithCode:[resource attribute:@"package"] language:language inContext:self.storage.backgroundObjectContext];
			}else{
				package = [packageArray objectAtIndex:0];
			}
			
			package.name			= [NSString stringWithUTF8String:[[resource attribute:@"name"] UTF8String]];
			NSLog(@"name: %@",package.name);
			package.configFile		= [resource attribute:@"config"];
			package.icon			= [resource attribute:@"icon"];
			package.status			= [resource attribute:@"status"];
			package.localVersion	= [resource attribute:@"version"];
			package.latestVersion	= [resource attribute:@"version"];
			
			
			[language addPackagesObject:package];
			
		}];
		
		language.downloaded = [NSNumber numberWithBool: YES];
		
		NSError *error;
		if (![[GTStorage sharedStorage].backgroundObjectContext save:&error]) {
			NSLog(@"error saving");
			return NO;
		} else {
			return YES;
		}
		
	} else {
		return NO;
	}
	
	return YES;
}

#pragma mark - Package update checking and downloading

- (void)checkForPackagesWithNewVersionsForLanguageCodes:(NSArray *)languageCodes {

	NSManagedObjectContext *context	= self.storage.backgroundObjectContext;
	NSFetchRequest *fetchRequest	= [[NSFetchRequest alloc] init];
	fetchRequest.entity				= [NSEntityDescription entityForName:NSStringFromClass([GTLanguage class]) inManagedObjectContext:context];
	//restrict list of languages to downloaded languages that match the languages listed in languageCodes (reverts to all downloaded languages if langugageCodes is empty or nil
	fetchRequest.predicate			= ( (languageCodes != nil && languageCodes.count > 0) ?
									   [NSPredicate predicateWithFormat:@"downloaded == TRUE AND code IN %@", languageCodes] :
									   [NSPredicate predicateWithFormat:@"downloaded == TRUE"]);
	
	NSArray *downloadedLanguages	= [context executeFetchRequest:fetchRequest error:nil];
	[self.packagesNeedingMajorUpdate removeAllObjects];
	[self.packagesNeedingMinorUpdate removeAllObjects];

    if (downloadedLanguages != nil && downloadedLanguages.count > 0) {
		
		NSError *error;
		__weak typeof(self)weakSelf = self;
		[downloadedLanguages enumerateObjectsUsingBlock:^(GTLanguage *language, NSUInteger index, BOOL *stop) {
			
			[language.packages enumerateObjectsUsingBlock:^(GTPackage *package, BOOL *stop) {
				
				if (package.needsMajorUpdate) {
					
					[weakSelf.packagesNeedingMajorUpdate addObject:package];
					package.language.updatesAvailable =  @YES;
					
				} else if (package.needsMinorUpdate) {
					
					[weakSelf.packagesNeedingMinorUpdate addObject:package];
					package.language.updatesAvailable =  @YES;
					
				}
				
			}];
			
		}];
		
		if (![self.storage.backgroundObjectContext save:&error]) {
			NSLog(@"Error saving updates");
		}
		
		if (self.packagesNeedingMajorUpdate.count > 0 || self.packagesNeedingMinorUpdate.count > 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationNewVersionsAvailable
																object:self
															  userInfo:@{GTDataImporterNotificationNewVersionsAvailableKeyNumberAvailable: @(self.packagesNeedingMajorUpdate.count + self.packagesNeedingMinorUpdate.count) }];
		}
		
    }
}

- (void)updatePackagesWithNewVersions {
	
	[self updatePackagesForLanguage:nil];
	
}

- (void)updatePackagesForLanguage:(GTLanguage *)language {
	
	NSArray *packages = [self.packagesNeedingMajorUpdate arrayByAddingObjectsFromArray:self.packagesNeedingMinorUpdate];
	[self.updateTracker updateInitiatedForLanguage:language withPackages:packages];
	
	__weak typeof(self)weakSelf = self;
	
    [self.packagesNeedingMajorUpdate enumerateObjectsUsingBlock:^(GTPackage *package, NSUInteger index, BOOL *stop) {
		
		if (language == nil || [package.language.code isEqualToString:language.code]) {
			
			[weakSelf downloadPackage:package];
		}
        
    }];
	
	[self.packagesNeedingMinorUpdate enumerateObjectsUsingBlock:^(GTPackage *package, NSUInteger index, BOOL *stop) {
		
		if (language == nil || [package.language.code isEqualToString:language.code]) {
			
			[weakSelf downloadXmlFilesForPackage:package];
		}
		
	}];

}

- (void)cleanUpAfterDownloadingPackage:(GTPackage *)package {
	
	if ( [self.updateTracker hasFinishedUpdatingLanguage:package.language] ) {
		
		package.language.downloaded			= [NSNumber numberWithBool:YES];
		package.language.updatesAvailable	= [NSNumber numberWithBool:NO];
		
	}
	
	NSError *error;
	if (![self.storage.backgroundObjectContext save:&error]) {
		
		NSLog(@"error saving");
	}
	
	[[GTDefaults sharedDefaults] setTranslationDownloadStatus:@"finished"];
	
}

- (void)addUpdateTrackingCallbacks {
	
	__weak typeof(self)weakSelf = self;
	[[NSNotificationCenter defaultCenter] addObserverForName:GTDataImporterNotificationPackageDownloadFailed
													  object:self
													   queue:nil
												  usingBlock:^(NSNotification *note) {
													  
													  GTPackage *package = note.userInfo[GTDataImporterNotificationPackageKeyPackage];
													  [weakSelf.updateTracker updateFailedForPackage:package];
												  }];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:GTDataImporterNotificationPackageDownloadFinished
													  object:self
													   queue:nil
												  usingBlock:^(NSNotification *note) {
													  
													  GTPackage *package = note.userInfo[GTDataImporterNotificationPackageKeyPackage];
													  [weakSelf.updateTracker updateCompletedForPackage:package];
												  }];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:GTDataImporterNotificationPackageXmlDownloadFailed
													  object:self
													   queue:nil
												  usingBlock:^(NSNotification *note) {
													  
													  GTPackage *package = note.userInfo[GTDataImporterNotificationPackageKeyPackage];
													  [weakSelf.updateTracker updateFailedForPackage:package];
												  }];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:GTDataImporterNotificationPackageXmlDownloadFinished
													  object:self
													   queue:nil
												  usingBlock:^(NSNotification *note) {
													  
													  GTPackage *package = note.userInfo[GTDataImporterNotificationPackageKeyPackage];
													  [weakSelf.updateTracker updateCompletedForPackage:package];
												  }];
	
}


#pragma mark - Translator Mode
-(void)authorizeTranslator :(NSString *)accessCode{

    __weak typeof(self)weakSelf = self;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationAuthTokenUpdateStarted object:self];
    
    NSLog(@"access code: %@",accessCode);
    
    [weakSelf.api getAuthTokenWithAccessCode:accessCode success:^(NSURLRequest *request, NSHTTPURLResponse *response,NSString *authToken) {

        [[GTDefaults sharedDefaults]setIsInTranslatorMode:[NSNumber numberWithBool:YES]];
        [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationAuthTokenUpdateSuccessful object:self];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) { 
        //NSLog(@"failure response: %@",response.allHeaderFields);
        if(response.statusCode == 401){
            NSString *errorMessage	= NSLocalizedString(@"invalid_code", nil);
            error = [NSError errorWithDomain:GTDataImporterErrorDomain
                                                 code:GTDataImporterErrorCodeInvalidXml
                                             userInfo:@{NSLocalizedDescriptionKey: errorMessage, }];
            NSDictionary *data = [NSDictionary dictionaryWithObject:error
                                                             forKey:@"Error"];

            [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationAuthTokenUpdateFail object:self userInfo:data];
        }else{
			NSDictionary *data = [NSDictionary dictionaryWithObject:error
															 forKey:@"Error"];
			[[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationAuthTokenUpdateFail object:self userInfo:data];
        }
    }];
}

- (void)downloadDraftsForLanguage:(GTLanguage *)language {
    
   	NSParameterAssert(language.code);
    
    __weak typeof(self)weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadStarted object:self];
    
    [weakSelf.api getDraftsResourcesForLanguage:language
                            progress:^(NSNumber *percentage) {
        
                                [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadProgressMade
                                                            object:weakSelf
                                                          userInfo:@{GTDataImporterNotificationLanguageDraftsDownloadPercentageKey: percentage}];
        
                            } success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath) {
                                if(response.statusCode == 200){
                                     RXMLElement *contents =[weakSelf.packageExtractor unzipResourcesAtTarget:targetPath forLanguage:language package:nil];
                                     NSError *error;
                                     if(contents!=nil){
                                         //Update storage with data from contents.
                                         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@"draft"];
                                         
                                         [language removePackages:[language.packages filteredSetUsingPredicate:predicate]];
                                         [contents iterate:@"resource" usingBlock: ^(RXMLElement *resource) {

                                             NSString *existingIdentifier = [GTPackage identifierWithPackageCode:[resource attribute:@"package"] languageCode:language.code];
                                             
                                             GTPackage *package;
                                             
                                             NSArray *packageArray = [self.storage fetchArrayOfModels:[GTPackage class] usingKey:@"identifier" forValues:@[existingIdentifier] inBackground:YES];
                                             
                                             if([packageArray count]==0){
                                                 package = [GTPackage packageWithCode:[resource attribute:@"package"] language:language inContext:self.storage.backgroundObjectContext];
                                                 
                                                
                                             }else{
                                                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@"draft"];
                                                 
                                                 NSArray *filteredArray = [packageArray filteredArrayUsingPredicate:predicate];
                                                 package =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
                                                 //NSLog(@"PACKAGE");
                                                 if(!package){

                                                     package = [GTPackage packageWithCode:[resource attribute:@"package"] language:language inContext:self.storage.backgroundObjectContext];
                                                     package.latestVersion = [resource attribute:@"version"];
                                                 }else{
                                                     //[language removePackagesObject:package];
                                                 }
                                             }
                                             
                                             package.name			= [resource attribute:@"name"];
                                             package.configFile		= [resource attribute:@"config"];
                                             package.icon			= [resource attribute:@"icon"];
                                             package.status			= [resource attribute:@"status"];
                                             package.localVersion	= [resource attribute:@"version"];
                                             
                                             [language addPackagesObject:package];
                                             
                                         }];    
                                         
                                         language.downloaded = [NSNumber numberWithBool: YES];
                                         if (![self.storage.backgroundObjectContext save:&error]) {
                                             NSLog(@"error saving drafts");
                                         }else{
                                             //this is to catch the error from the empty live packages
                                             if([GTDefaults sharedDefaults].isChoosingForMainLanguage){
                                                 
                                                 if([[[GTDefaults sharedDefaults]currentParallelLanguageCode] isEqualToString:language.code]){
                                                     
                                                     [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:nil];
                                                 }
                                                 
                                                 
                                                 [[GTDefaults sharedDefaults]setCurrentLanguageCode:language.code];
                                                 
                                             }else{
                                                 NSLog(@"set %@ as parallel",language.name );
                                                 [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:language.code];
                                             }

                                         }
                                         
                                         [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadFinished object:self];
                                     }
                                }else{
                                    NSLog(@"error. response is: %@",response);
                                    if(response.statusCode == 404){
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@"draft"];
                                        
                                        [language removePackages:[language.packages filteredSetUsingPredicate:predicate]];
                                        
                                        NSError *error;
                                        if (![self.storage.backgroundObjectContext save:&error]) {
                                            NSLog(@"error saving");
                                        }
                                    }else if(response.statusCode == 500){
                                        NSString *errorMessage	= NSLocalizedString(@"server_error", nil);
                                        NSError *error = [NSError errorWithDomain:GTDataImporterErrorDomain
                                                                             code:GTDataImporterErrorCodeInvalidXml
                                                                         userInfo:@{NSLocalizedDescriptionKey: errorMessage, }];
                                        [weakSelf displayDownloadPackagesRequestError:error];
                                    }
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadFinished object:self];
                                }
                                
                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                 NSLog(@"Failute here..");
                                 [weakSelf displayDownloadPackagesRequestError:error];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadFinished object:self];
                                 
                             }];
}

-(void)downloadPageForLanguage:(GTLanguage *)language package:(GTPackage *)package pageID:(NSString *)pageID {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationDownloadPageStarted
                                                        object:self
                                                      userInfo:nil];
	
	__weak typeof(self)weakSelf = self;
    [self.api getPageForLanguage:language
						 package:package
						  pageID:pageID
                        progress:^(NSNumber *percentage) {
        
                            
                        } success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath) {
                            NSLog(@"success donwload of page");
                            @try {
                                //unzip
                                [weakSelf.packageExtractor unzipXMLAtTarget:targetPath forPage:pageID];
                                [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationDownloadPageSuccessful
                                                                                    object:weakSelf
                                                                                  userInfo:nil];
                            }
                            @catch (NSException *exception) {
                                NSString *errorMessage	= NSLocalizedString(@"page_download_error", nil);
                                NSError *error = [NSError errorWithDomain:GTDataImporterErrorDomain
                                                                        code:GTDataImporterErrorCodeInvalidXml
                                                                    userInfo:@{NSLocalizedDescriptionKey: errorMessage,
                                                                               NSLocalizedFailureReasonErrorKey: exception.description }];
                                [weakSelf displayDownloadPackagesRequestError:error];

                                [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationDownloadPageFail
                                                                                    object:weakSelf
                                                                                  userInfo:nil];

                            }
                            

                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                            
                            [weakSelf displayDownloadPackagesRequestError:error];
                            NSLog(@"page download fail");
                            [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationDownloadPageFail
                                                                                object:weakSelf
                                                                              userInfo:nil];
                        }];
}

- (void)createDraftsForLanguage:(GTLanguage *)language package:(GTPackage *)package{
    __weak typeof(self)weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationCreateDraftStarted
                                                        object:weakSelf
                                                      userInfo:nil];
    
    [self.api createDraftsForLanguage:language package:package success:^(NSURLRequest *request, NSHTTPURLResponse *response) {
        //check response
        if(response.statusCode == 201){//, created
            NSLog(@"created");
            [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationCreateDraftSuccessful object:self];
        }
        else if(response.statusCode == 401){//, unauthorized
            NSLog(@"Unauthorized");
            [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationCreateDraftFail object:self];

        }
        else if(response.statusCode == 404){//, not found
            NSLog(@"Not found");
            [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationCreateDraftFail object:self];
        }
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"creation error: %@", error);
        [weakSelf displayDownloadPageRequestError:error];
        [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationCreateDraftFail object:self];
    }];
    
}

- (void)publishDraftForLanguage:(GTLanguage *)language package:(GTPackage *)package{
    __weak typeof(self)weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationPublishDraftStarted
                                                        object:weakSelf
                                                      userInfo:nil];
    
    [self.api publishTranslationForLanguage:language package:package success:^(NSURLRequest *request, NSHTTPURLResponse *response) {
        //check response
        if(response.statusCode == 204){//, created
            NSLog(@"published");
            [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationPublishDraftSuccessful object:self];
        }
        else if(response.statusCode == 401){//, unauthorized
            NSLog(@"Unauthorized");
            [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationPublishDraftFail object:self];
            
        }
        else if(response.statusCode == 404){//, not found
            NSLog(@"Not found");
            [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationPublishDraftFail object:self];
        }
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"publishing error: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationPublishDraftFail object:self];
    }];
    
}




#pragma mark - Error Handling

- (void)displayMenuInfoRequestError:(NSError *)error {
	
	[self.api.errorHandler displayError:error];
	
}

- (void)displayMenuInfoImportError:(NSError *)error {
	
	[self.storage.errorHandler displayError:error];
	
}

- (void)displayPackageImportError:(NSError *)error {
	
	[self.storage.errorHandler displayError:error];
	
}

- (void)displayDownloadPackagesRequestError:(NSError *)error {
    NSString *errorMessage	= NSLocalizedString(@"packages_download_error", nil);
    NSError *downloadError = [NSError errorWithDomain:GTDataImporterErrorDomain
                                              code:GTDataImporterErrorCodeInvalidZip
                                          userInfo:@{NSLocalizedDescriptionKey: errorMessage,
                                                    }];
	[self.storage.errorHandler displayError:downloadError];
	
}

-(void)displayDownloadPageRequestError:(NSError *)error{
    [self.storage.errorHandler displayError:error];
}

-(void)displayAuthorizeTranslatorRequestError:(NSError *)error{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationAuthTokenUpdateFail object:self];
    
    [self.storage.errorHandler displayError:error];
    
}

@end
