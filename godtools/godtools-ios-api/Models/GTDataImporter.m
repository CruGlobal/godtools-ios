//
//  GTDataImporter.m
//  godtools
//
//  Created by Michael Harrison on 3/18/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTDataImporter.h"

#import "GTResourceLog+Helper.h"

@interface GTDataImporter ()

@property (nonatomic, strong) GTAPI			*api;
@property (nonatomic, strong) GTResourceLog	*resourceLog;

@end

@implementation GTDataImporter

+ (instancetype)sharedImporter {
	
    static GTDataImporter *_sharedImporter = nil;
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{
        _sharedImporter = [[GTDataImporter alloc] initWithAPI:[GTAPI sharedAPI]];
    });
	
    return _sharedImporter;
}

- (instancetype)initWithAPI:(GTAPI *)api {
	
	self = [self init];
    if (self) {
        
		self.api	= api;
		
    }
	
    return self;
}

- (void)updateMenuInfo {
	
	
	
}

- (void)updatePackagesForLanguage {
	
	
	
}

@end
