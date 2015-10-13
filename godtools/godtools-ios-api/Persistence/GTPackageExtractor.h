//
//  GTPackageExtractor.h
//  godtools
//
//  Created by Michael Harrison on 8/24/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RXMLElement.h"
#import "GTLanguage.h"
#import "GTPackage.h"

extern NSString * const GTPackageExtractorNotificationUnzippingFailed;
extern NSString * const GTPackageExtractorNotificationUnzippingFailedKeyTarget;
extern NSString * const GTPackageExtractorNotificationUnzippingFailedKeyLangauge;
extern NSString * const GTPackageExtractorNotificationUnzippingFailedKeyPackage;
extern NSString * const GTPackageExtractorNotificationUnzippingFailedKeyPageID;

@interface GTPackageExtractor : NSObject

+ (instancetype)sharedPackageExtractor;

- (RXMLElement *)unzipResourcesAtTarget:(NSURL *)targetPath forLanguage:(GTLanguage *)language package:(GTPackage *)package;
- (NSError *)unzipXMLAtTarget:(NSURL *)targetPath forPage:(NSString *)pageID;

@end
