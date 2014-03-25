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

@interface GTDataImporter ()

@property (nonatomic, strong, readonly) GTAPI			*api;
@property (nonatomic, strong, readonly)	GTStorage		*storage;
@property (nonatomic, strong, readonly) GTDefaults		*defaults;
@property (nonatomic, strong)			NSDate			*lastMenuInfoUpdate;
@property (nonatomic, strong)			NSMutableArray	*packagesNeedingToBeUpdated;

- (void)persistMenuInfoFromXMLElement:(RXMLElement *)rootElement;
- (void)displayMenuInfoRequestError:(NSError *)error;

- (void)cleanUpMenuImportFailureWithError:(NSError *)error;
- (void)fireMenuImportSuccessNotifications;
	
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
        
		_api		= api;
		_storage	= storage;
		_defaults	= defaults;
	
		self.packagesNeedingToBeUpdated	= [NSMutableArray array];
		
    }
	
    return self;
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

- (void)persistMenuInfoFromXMLElement:(RXMLElement *)rootElement {
	
	NSMutableArray *languageCodes		= [NSMutableArray array];
	NSMutableArray *packageCodes		= [NSMutableArray array];
	
	//collect language and package codes for database fetch
	[rootElement iterate:@"language" usingBlock:^(RXMLElement *languageElement) {
		
		NSString *languageCode = [languageElement attribute:@"code"];
		[languageCodes addObject:languageCode];
		
		[languageElement iterate:@"packages.package" usingBlock:^(RXMLElement *packageElement) {
			
			NSString *packageCode	= [packageElement attribute:@"code"];
			NSString *identifier	= [GTPackage identifierWithPackageCode:packageCode languageCode:languageCode];
			[packageCodes addObject:identifier];
			
		}];
		
	}];
	
	//fetch and prepare the available languages from the database
	NSMutableDictionary *languageObjects	= [NSMutableDictionary dictionary];
	NSArray *languageArray = [self.storage fetchArrayOfModels:[GTLanguage class]
													 usingKey:@"code"
													forValues:languageCodes
												 inBackground:YES];
	
	[languageArray enumerateObjectsUsingBlock:^(GTLanguage *language, NSUInteger index, BOOL *stop) {
		
		languageObjects[language.code]	= language;
		
	}];
	
	//fetch and prepare the available languages from the database
	NSMutableDictionary *packageObjects	= [NSMutableDictionary dictionary];
	NSArray *packageArray = [self.storage fetchArrayOfModels:[GTPackage class]
													usingKey:@"identifier"
												   forValues:packageCodes
												inBackground:YES];
	
	[packageArray enumerateObjectsUsingBlock:^(GTPackage *package, NSUInteger index, BOOL *stop) {
		
		packageObjects[package.identifier]	= package;
		
	}];
	
	//update data
#warning incomplete implementation of persistMenuInfoFromXMLElement
	[rootElement iterate:@"language" usingBlock:^(RXMLElement *languageElement) {
		
		//update language
		NSString *languageCode		= [languageElement attribute:@"code"];
		GTLanguage *language		= languageObjects[languageCode];
		
		if (!language) {
			
			language						= [GTLanguage languageWithCode:languageCode inContext:self.storage.backgroundObjectContext];
			languageObjects[languageCode]	= language;
			
		}
		
		[languageElement iterate:@"packages.package" usingBlock:^(RXMLElement *packageElement) {
			
			//update package
			NSString *packageCode	= [packageElement attribute:@"code"];
			NSString *identifier	= [GTPackage identifierWithPackageCode:packageCode languageCode:languageCode];
			NSNumber *version		= @([[packageElement attribute:@"version"] integerValue]);
			
			GTPackage *package		= packageObjects[identifier];
			
			if (!package) {
				
				package						= [GTPackage packageWithCode:packageCode language:language inContext:self.storage.backgroundObjectContext];
				packageObjects[identifier]	= package;
				
			} else {
				
				if ([self.defaults.currentLanguageCode isEqualToString:languageCode] ||
					[self.defaults.currentParallelLanguageCode isEqualToString:languageCode] ||
					package.version < version) {
					
					[self.packagesNeedingToBeUpdated addObject:package];
					
				}
				
			}
			
			package.icon			= [packageElement attribute:@"icon"];
			package.name			= [packageElement attribute:@"name"];
			package.status			= [packageElement attribute:@"status"];
			package.type			= [packageElement attribute:@"type"];
			package.version			= version;
			
			[packageObjects removeObjectForKey:identifier];
			
		}];
		
	}];
	
	//save data to the database
	NSError *error;
	if ([self.storage.backgroundObjectContext save:&error]) {
		
		[self fireMenuImportSuccessNotifications];
		
	} else {
		
		[self cleanUpMenuImportFailureWithError:error];
		
	}
	
}

- (void)displayMenuInfoRequestError:(NSError *)error {
	
	[self.api.errorHandler displayError:error];
	
}

- (void)fireMenuImportSuccessNotifications {
	
	if (self.packagesNeedingToBeUpdated.count > 0) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.godtoolsapp.GTDataImporter.notifications.updateNeeded" object:self];
		
	}
	
}

- (void)cleanUpMenuImportFailureWithError:(NSError *)error {
	
	[self.storage.errorHandler displayError:error];
	
#warning make conditional if there is an error that can be recovered from
	[self.packagesNeedingToBeUpdated removeAllObjects];
	
}

- (void)updatePackagesForLanguage {
	
	
	
}

@end
