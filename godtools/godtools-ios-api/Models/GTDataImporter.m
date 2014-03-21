//
//  GTDataImporter.m
//  godtools
//
//  Created by Michael Harrison on 3/18/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTDataImporter.h"

#import "RXMLElement.h"
#import "GTResourceLog+Helper.h"

@interface GTDataImporter ()

@property (nonatomic, strong, readonly) GTAPI			*api;
@property (nonatomic, strong, readonly)	GTStorage		*storage;
@property (nonatomic, strong)			GTResourceLog	*resourceLog;
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
	
	NSMutableArray *languages	= [NSMutableArray array];
	NSMutableArray *packages	= [NSMutableArray array];
	
	[rootElement iterate:@"language" usingBlock:^(RXMLElement *language) {
		
		NSString *languageCode = [language attribute:@"code"];
		[languages addObject:languageCode];
		
		[language iterate:@"packages.package" usingBlock:^(RXMLElement *package) {
			
			NSString *packageCode	= [package attribute:@"code"];
			NSString *identifier	= [languageCode stringByAppendingFormat:@"-%@", packageCode];
			[packages addObject:identifier];
			
		}];
		
	}];
	
}

- (void)displayMenuInfoRequestError:(NSError *)error {
	
	[self.api.errorHandler displayError:error];
	
}

- (void)updatePackagesForLanguage {
	
	
	
}

@end
