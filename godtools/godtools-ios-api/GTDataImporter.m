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
#import <GTViewController/GTFileLoader.h>

NSString *const GTDataImporterErrorDomain								= @"com.godtoolsapp.GTDataImporter.errorDomain";

NSInteger const GTDataImporterErrorCodeInvalidXml						= 1;
NSInteger const GTDataImporterErrorCodeInvalidZip                       = 2;

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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationMenuUpdateStarted
                                                        object:weakSelf
                                                      userInfo:nil];

	[self.api getMenuInfoSince:self.lastMenuInfoUpdate
					   success:^(NSURLRequest *request, NSHTTPURLResponse *response, RXMLElement *XMLRootElement) {
						   
						   @try {

							   [weakSelf persistMenuInfoFromXMLElement:XMLRootElement];
                               
                               [[NSNotificationCenter defaultCenter]
                                    postNotificationName:GTDataImporterNotificationMenuUpdateFinished
                                    object:weakSelf
                                    userInfo:nil];
						   
						   } @catch (NSException *exception) {

							   NSString *errorMessage	= NSLocalizedString(@"GTDataImporter_updateMenuInfo_bad_xml", @"Error message when meta endpoint response is missing data.");
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
			
        }else{
            NSLog(@"NO ERROR saving to storage");
        }

		//check for updates in current languages
        NSArray *currentCodes;
        if(self.defaults.currentParallelLanguageCode){
            currentCodes = @[self.defaults.currentLanguageCode, self.defaults.currentParallelLanguageCode];
        }else{
            currentCodes = @[self.defaults.currentLanguageCode];
        }
        
		//[self checkForPackagesWithNewVersionsForLanguageCodes:currentCodes];
		
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
            language.name                   = [languageElement attribute:@"name"];
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
    
    //NSLog(@"packageObjects: %@",packageObjects);

    if([[[languageElement child:@"packages"] children:@"package"]count] > 0){
        [languageElement iterate:GTDataImporterPackageMetaXmlPathRelativeToLanguage usingBlock:^(RXMLElement *packageElement) {

            //update package
            NSString *packageCode	= [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameCode];
           
            NSString *identifier	= [GTPackage identifierWithPackageCode:packageCode languageCode:languageCode];

            NSNumber *version		= @([[packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameVersion] integerValue]);
            
            GTPackage *package		= packageObjects[identifier];
            //NSLog(@"package: %@",package.identifier);
            
            if (!package) {
                package						= [GTPackage packageWithCode:packageCode language:language inContext:self.storage.backgroundObjectContext];
                packageObjects[identifier]	= package;
                
            }else{
                NSLog(@"update %@ - %@",identifier, package.status);
                if(![package.status isEqualToString:[packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameStatus]]){
                    NSLog(@"create new for %@", [packageElement attribute:GTDataImporterPackageMetaXmlAttributeNameStatus]);
                    package						= [GTPackage packageWithCode:packageCode language:language inContext:self.storage.backgroundObjectContext];
                    packageObjects[identifier]	= package;
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
            package.latestVersion	= version;
            package.localVersion    = version;
            
            [packageObjects removeObjectForKey:identifier];
            
        }];
    }
	
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
                                 if(response.statusCode == 200){
                                     RXMLElement *contents =[weakSelf unzipResourcesAtTarget:targetPath forLanguage:language package:nil];
                                     NSError *error;
                                     if(contents!=nil){
                                         //Update storage with data from contents.
                                         [language removePackages:language.packages];
                                         [contents iterate:@"resource" usingBlock: ^(RXMLElement *resource) {
                                             
                                             NSString *existingIdentifier = [GTPackage identifierWithPackageCode:[resource attribute:@"package"] languageCode:language.code];
                                             
                                             GTPackage *package;
                                             
                                             NSArray *packageArray = [[GTStorage sharedStorage]fetchArrayOfModels:[GTPackage class] usingKey:@"identifier" forValues:@[existingIdentifier] inBackground:YES];
                                             
                                             if([packageArray count]==0){
                                                 package = [GTPackage packageWithCode:[resource attribute:@"package"] language:language inContext:[GTStorage sharedStorage].backgroundObjectContext];
                                                 package.latestVersion = [NSNumber numberWithFloat:[[resource attribute:@"version"] floatValue]];
                                             }else{
                                                 package = [packageArray objectAtIndex:0];
                                             }
                                             
                                             package.name = [NSString stringWithUTF8String:[[resource attribute:@"name"] UTF8String]];
                                             NSLog(@"name: %@",package.name);
                                             package.configFile = [resource attribute:@"config"];
                                             package.icon = [resource attribute:@"icon"];
                                             package.status = [resource attribute:@"status"];
                                             package.localVersion = [NSNumber numberWithFloat:[[resource attribute:@"version"] floatValue] ];

                                             
                                             [language addPackagesObject:package];
                                             
                                         }];
                                         
                                         language.downloaded = [NSNumber numberWithBool: YES];
                                         if (![[GTStorage sharedStorage].backgroundObjectContext save:&error]) {
                                             NSLog(@"error saving");
                                         }else{
                                             if([[GTDefaults sharedDefaults] isChoosingForMainLanguage] == [NSNumber numberWithBool:YES]){
                                                 
                                                 if([[[GTDefaults sharedDefaults]currentParallelLanguageCode] isEqualToString:language.code]){
                                                     //[[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:[[GTDefaults sharedDefaults] currentLanguageCode]];
                                                     [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:nil];
                                                 }
                                                 
                                                 
                                                 [[GTDefaults sharedDefaults]setCurrentLanguageCode:language.code];
                                                 
                                             }else{
                                                 
                                                 [[GTDefaults sharedDefaults]setCurrentParallelLanguageCode:language.code];
                                             }
                                         }
                                     }
                                 }else if(response.statusCode == 500){
                                    NSString *errorMessage	= NSLocalizedString(@"GTDataImporter_downloadPackages_error", @"Error message when package endpoint response is missing data.");
                                     NSError *error = [NSError errorWithDomain:GTDataImporterErrorDomain
                                                                             code:GTDataImporterErrorCodeInvalidXml
                                                                         userInfo:@{NSLocalizedDescriptionKey: errorMessage, }];
                                     [weakSelf displayDownloadPackagesRequestError:error];
                                 }
                                 if([[GTDefaults sharedDefaults] isInTranslatorMode]== [NSNumber numberWithBool:YES]){
                                     [self downloadDraftsForLanguage:language];
                                 }else{
                                     [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDownloadFinished object:self];
                                 }
							 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                 
								 [weakSelf displayDownloadPackagesRequestError:error];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDownloadFinished object:self];
								 
							 }];

	
}

- (RXMLElement *)unzipResourcesAtTarget:(NSURL *)targetPath forLanguage:(GTLanguage *)language package:(GTPackage *)package {
    
	NSParameterAssert(language.code || package.code);
	
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *temporaryFolderName	= [[NSUUID UUID] UUIDString];
    NSString* temporaryDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:temporaryFolderName];
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:temporaryDirectory]){    //Does directory already exist?
        if (![[NSFileManager defaultManager] createDirectoryAtPath:temporaryDirectory withIntermediateDirectories:NO attributes:nil error:&error]){
            NSLog(@"Create directory error: %@", error);
        }
    }
    
    if(![SSZipArchive unzipFileAtPath:[targetPath absoluteString]
                        toDestination:temporaryDirectory
                            overwrite:NO
                             password:nil
                                error:&error
                             delegate:nil]) {
        
        [self displayDownloadPackagesUnzippingError:error];
        [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDownloadFinished object:self];
    }
    
    if(!error){

        RXMLElement *element = [RXMLElement elementFromXMLData:[NSData dataWithContentsOfFile:[temporaryDirectory stringByAppendingPathComponent:@"contents.xml"]]];
        
        //move to Packages folder
        NSString *destinationPath = [GTFileLoader pathOfPackagesDirectory];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if (![fm fileExistsAtPath:destinationPath]){ //Create directory
            if (![[NSFileManager defaultManager] createDirectoryAtPath:destinationPath withIntermediateDirectories:NO  attributes:nil error:&error]){
                NSLog(@"Create directory error: %@", error);
            }
        }
        
        for (NSString *file in [fm contentsOfDirectoryAtPath:temporaryDirectory error:&error]) {
            NSString *filepath = [NSString stringWithFormat:@"%@/%@",temporaryDirectory,file];
            NSString *destinationFile = [NSString stringWithFormat:@"%@/%@",destinationPath,file];
            if(![file  isEqual: @"contents.xml"]){ //&& ![fm fileExistsAtPath:destinationFile]){
                if([fm fileExistsAtPath:destinationFile]){
                    //NSLog(@"file exist: %@", destinationFile);
                    [fm removeItemAtPath:destinationFile error:&error];
                }
                BOOL success = [fm copyItemAtPath:filepath toPath:destinationFile error:&error] ;
                if (!success || error) {
                    NSLog(@"Error: %@ file: %@",[error description],file);
                }else{
                    [fm removeItemAtPath:filepath error:&error];
                }
            }
        }
        
        if(!error){ //No error moving files
            [fm removeItemAtPath:temporaryDirectory error:&error];
            [fm removeItemAtPath:[targetPath absoluteString] error:&error];
        }
        return element;
        
    }else{
        
        [[NSFileManager defaultManager] removeItemAtPath:temporaryDirectory error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:[targetPath absoluteString] error:&error];
    }

    return nil;

	
}

- (NSError *)unzipXMLAtTarget:(NSURL *)targetPath forPage:(NSString *)pageID {
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@.xml",pageID];
    NSString *fileDownloadDestinationPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:pageID];
    
    if(![SSZipArchive unzipFileAtPath:[targetPath absoluteString]
                        toDestination:fileDownloadDestinationPath
                            overwrite:NO
                             password:nil
                                error:&error
                             delegate:nil]) {
        
        [self displayDownloadPackagesUnzippingError:error];
        [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDownloadFinished object:self];
    }
    
    if(!error){
        
        //RXMLElement *element = [RXMLElement elementFromXMLData:[NSData dataWithContentsOfFile:[temporaryDirectory stringByAppendingPathComponent:@"contents.xml"]]];
        
        //move to Packages folder
        NSString *destinationPath = [GTFileLoader pathOfPackagesDirectory];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if (![fm fileExistsAtPath:destinationPath]){ //Create directory
            if (![[NSFileManager defaultManager] createDirectoryAtPath:destinationPath withIntermediateDirectories:NO  attributes:nil error:&error]){
                NSLog(@"Create directory error: %@", error);
            }
        }
        for (NSString *file in [fm contentsOfDirectoryAtPath:fileDownloadDestinationPath error:&error]) {
            NSString *filepath = [NSString stringWithFormat:@"%@/%@",fileDownloadDestinationPath,file];
            NSString *destinationFile = [NSString stringWithFormat:@"%@/%@",destinationPath,file];
            if([fm fileExistsAtPath:destinationFile]){
                //NSLog(@"file exist: %@", destinationFile);
                [fm removeItemAtPath:destinationFile error:&error];
            }
            BOOL success = [fm copyItemAtPath:filepath toPath:destinationFile error:&error] ;
            if (!success || error) {
                NSLog(@"Error: %@ file: %@",[error description],file);
                return error;
            }else{
                [fm removeItemAtPath:fileDownloadDestinationPath error:&error];
                return nil;
            }
        }
        
    }else{
        return error;
    }
    
    return nil;
    
    
}


#pragma mark - Package update checking and downloading

- (void)checkForPackagesWithNewVersionsForLanguageCodes:(NSArray *)languageCodes {
	
	NSParameterAssert(languageCodes.count);

	NSManagedObjectContext *context	= self.storage.backgroundObjectContext;
	NSArray *currentLanguages		= languageCodes;
	NSFetchRequest *fetchRequest	= [[NSFetchRequest alloc] init];
	fetchRequest.entity				= [NSEntityDescription entityForName:NSStringFromClass([GTPackage class]) inManagedObjectContext:context];
	fetchRequest.predicate			= [NSPredicate predicateWithFormat:@"(localVersion < latestVersion) && language.code IN %@", currentLanguages];
	
	NSArray *fetchedObjects			= [context executeFetchRequest:fetchRequest error:nil];
	self.packagesNeedingToBeUpdated = [fetchedObjects mutableCopy];

    if (self.packagesNeedingToBeUpdated.count > 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationNameUpdateNeeded object:self];
        [self updatePackagesWithNewVersions];
    }
}

- (void)updatePackagesWithNewVersions {
	
    NSError *error;
    [self.packagesNeedingToBeUpdated enumerateObjectsUsingBlock:^(GTPackage *package, NSUInteger index, BOOL *stop) {
        
        package.language.downloaded =  [NSNumber numberWithBool: NO];
        
    }];
    
    if (![[GTStorage sharedStorage].backgroundObjectContext save:&error]) {
        NSLog(@"Error saving updates");
    }

}


#pragma mark - Translator Mode
-(void)authorizeTranslator{

    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationAuthTokenUpdateStarted object:self];
    NSString *accessCode = [[GTDefaults sharedDefaults]translatorAccessCode];
    NSLog(@"access code: %@",accessCode);
    [[GTAPI sharedAPI]getAuthTokenWithAccessCode:accessCode success:^(NSURLRequest *request, NSHTTPURLResponse *response,NSString *authToken) {
        
        [[GTAPI sharedAPI]setAuthToken:authToken];
        //NSLog(@"translator token: %@",authToken);
        [[GTDefaults sharedDefaults]setIsInTranslatorMode:[NSNumber numberWithBool:YES]];
        [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationAuthTokenUpdateSuccessful object:self];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) { 
        //NSLog(@"failure response: %@",response.allHeaderFields);
        [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationAuthTokenUpdateFail object:self];
    }];
}

- (void)downloadDraftsForLanguage:(GTLanguage *)language {
    
   	NSParameterAssert(language.code);
    
    __weak typeof(self)weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadStarted object:self];
    
    [self.api getDraftsResourcesForLanguage:language
                            progress:^(NSNumber *percentage) {
        
                                [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadProgressMade
                                                            object:weakSelf
                                                          userInfo:@{GTDataImporterNotificationLanguageDraftsDownloadPercentageKey: percentage}];
        
                            } success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath) {
                                if(response.statusCode == 200){
                                 RXMLElement *contents =[weakSelf unzipResourcesAtTarget:targetPath forLanguage:language package:nil];
                                 NSError *error;
                                 if(contents!=nil){
                                     //Update storage with data from contents.
                                     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@"draft"];
                                     
                                     [language removePackages:[language.packages filteredSetUsingPredicate:predicate]];
                                     [contents iterate:@"resource" usingBlock: ^(RXMLElement *resource) {

                                         NSString *existingIdentifier = [GTPackage identifierWithPackageCode:[resource attribute:@"package"] languageCode:language.code];
                                         
                                         GTPackage *package;
                                         
                                         NSArray *packageArray = [[GTStorage sharedStorage]fetchArrayOfModels:[GTPackage class] usingKey:@"identifier" forValues:@[existingIdentifier] inBackground:YES];
                                         
                                         if([packageArray count]==0){
                                             package = [GTPackage packageWithCode:[resource attribute:@"package"] language:language inContext:[GTStorage sharedStorage].backgroundObjectContext];
                                             
                                            
                                         }else{
                                             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@"draft"];
                                             
                                             NSArray *filteredArray = [packageArray filteredArrayUsingPredicate:predicate];
                                             package =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
                                             //NSLog(@"PACKAGE");
                                             if(!package){

                                                 package = [GTPackage packageWithCode:[resource attribute:@"package"] language:language inContext:[GTStorage sharedStorage].backgroundObjectContext];
                                                 package.latestVersion = [NSNumber numberWithFloat:[[resource attribute:@"version"] floatValue] ];
                                             }else{
                                                 //[language removePackagesObject:package];
                                             }
                                         }
                                         
                                         package.name = [resource attribute:@"name"];
                                         package.configFile = [resource attribute:@"config"];
                                         package.icon = [resource attribute:@"icon"];
                                         package.status = [resource attribute:@"status"];
                                         package.localVersion = [NSNumber numberWithFloat:[[resource attribute:@"version"] floatValue] ];
                                         
                                         [language addPackagesObject:package];
                                         
                                     }];    
                                     
                                     language.downloaded = [NSNumber numberWithBool: YES];
                                     if (![[GTStorage sharedStorage].backgroundObjectContext save:&error]) {
                                         NSLog(@"error saving drafts");
                                     }else{

                                     }
                                     
                                     [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadFinished object:self];
                                 }
                                }else{
                                    NSLog(@"error. response is: %@",response);
                                    if(response.statusCode == 404){
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@"draft"];
                                        
                                        [language removePackages:[language.packages filteredSetUsingPredicate:predicate]];
                                        
                                        NSError *error;
                                        if (![[GTStorage sharedStorage].backgroundObjectContext save:&error]) {
                                            NSLog(@"error saving");
                                        }
                                    }
                                    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadFinished object:self];
                                }
                                
                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                 
                                 [weakSelf displayDownloadPackagesRequestError:error];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationLanguageDraftsDownloadFinished object:self];
                                 
                             }];
}

-(void)downloadPageForLanguage:(GTLanguage *)language package:(GTPackage *)package pageID:(NSString *)pageID{
    __weak typeof(self)weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationDownloadPageStarted
                                                        object:weakSelf
                                                      userInfo:nil];
    
    [self.api getPageForLanguage:language package:package pageID:pageID
                        progress:^(NSNumber *percentage) {
        
                            
                        } success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *targetPath) {
                            NSLog(@"success donwload of page");
                            @try {
                                //unzip
                                [self unzipXMLAtTarget:targetPath forPage:pageID];
                                [[NSNotificationCenter defaultCenter] postNotificationName:GTDataImporterNotificationDownloadPageSuccessful
                                                                                    object:weakSelf
                                                                                  userInfo:nil];
                            }
                            @catch (NSException *exception) {
                                NSString *errorMessage	= NSLocalizedString(@"GTDataImporter_downloadPage_error", @"Error message when pages endpoint response is missing data.");
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
        NSLog(@"Request: %@",request);
        NSLog(@"Response: %@",response);
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

- (void)displayDownloadPackagesUnzippingError:(NSError *)error {

	[self.storage.errorHandler displayError:error];

	
}

- (void)displayDownloadPackagesRequestError:(NSError *)error {
    NSString *errorMessage	= NSLocalizedString(@"GTDataImporter_downloadPackages_error", @"Error message when downloading package.");
    NSError *downloadError = [NSError errorWithDomain:GTDataImporterErrorDomain
                                              code:GTDataImporterErrorCodeInvalidZip
                                          userInfo:@{NSLocalizedDescriptionKey: errorMessage,
                                                    }];
	[self.storage.errorHandler displayError:downloadError];
	
}

-(void)displayDownloadPageRequestError:(NSError *)error{
    [self.storage.errorHandler displayError:error];
}

@end
