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
@property (nonatomic, strong)			NSDate			*lastMenuInfoUpdate;

- (void)persistMenuInfoFromXMLElement:(RXMLElement *)rootElement;
- (void)displayMenuInfoRequestError:(NSError *)error;

@end

@implementation GTDataImporter

+ (instancetype)sharedImporter {
	
    static GTDataImporter *_sharedImporter = nil;
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{
		
        _sharedImporter = [[GTDataImporter alloc] initWithAPI:[GTAPI sharedAPI]
													  storage:[GTStorage sharedStorage]];
		
    });
	
    return _sharedImporter;
}

- (instancetype)initWithAPI:(GTAPI *)api storage:(GTStorage *)storage {
	
	self = [self init];
    if (self) {
        
		_api		= api;
		_storage	= storage;
		
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
	
	NSMutableArray *languages			= [NSMutableArray array];
	NSMutableArray *packages			= [NSMutableArray array];
	
	//collect language and package ids for database fetch
	[rootElement iterate:@"language" usingBlock:^(RXMLElement *language) {
		
		NSString *languageCode = [language attribute:@"code"];
		[languages addObject:languageCode];
		
		[language iterate:@"packages.package" usingBlock:^(RXMLElement *package) {
			
			NSString *packageCode	= [package attribute:@"code"];
			NSString *identifier	= [languageCode stringByAppendingFormat:@"-%@", packageCode];
			[packages addObject:identifier];
			
		}];
		
	}];
	
	//fetch and prepare the available languages from the database
	NSMutableDictionary *languageObjects	= [NSMutableDictionary dictionary];
	NSArray *languageArray = [self.storage fetchArrayOfModels:[GTLanguage class]
													 usingKey:@"code"
													   forIDs:languages
												 inBackground:YES];
	
	[languageArray enumerateObjectsUsingBlock:^(GTLanguage *language, NSUInteger index, BOOL *stop) {
		
		languageObjects[language.code]	= language;
		
	}];
	
	//fetch and prepare the available languages from the database
	NSMutableDictionary *packageObjects	= [NSMutableDictionary dictionary];
	NSArray *packageArray = [self.storage fetchArrayOfModels:[GTPackage class]
													usingKey:@"identifier"
													  forIDs:packages
												inBackground:YES];
	
	[packageArray enumerateObjectsUsingBlock:^(GTPackage *package, NSUInteger index, BOOL *stop) {
		
		packageObjects[package.identifier]	= package;
		
	}];
	
	//update data
	[rootElement iterate:@"language" usingBlock:^(RXMLElement *language) {
		
		NSString *languageCode = [language attribute:@"code"];
		[languages addObject:languageCode];
		
		[language iterate:@"packages.package" usingBlock:^(RXMLElement *package) {
			
			NSString *packageCode	= [package attribute:@"code"];
			NSString *identifier	= [languageCode stringByAppendingFormat:@"-%@", packageCode];
			[packages addObject:identifier];
			
		}];
		
	}];
	
	//save data to the database
	NSError *error;
	[self.storage.backgroundObjectContext save:&error];
	if (error) {
		[self.storage.errorHandler displayError:error];
	}
	
#warning incomplete implementation of persistMenuInfoFromXMLElement
	
}

- (void)displayMenuInfoRequestError:(NSError *)error {
	
	[self.api.errorHandler displayError:error];
	
}

- (void)updatePackagesForLanguage {
	
	
	
}

@end
