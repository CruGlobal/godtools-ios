//
//  GTPackageExtractor.h
//  godtools
//
//  Created by Michael Harrison on 8/24/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RXMLElement.h"
#import "GTLanguage+Helper.h"
#import "GTPackage+Helper.h"

@interface GTPackageExtractor : NSObject

- (RXMLElement *)unzipResourcesAtTarget:(NSURL *)targetPath forLanguage:(GTLanguage *)language package:(GTPackage *)package;
- (NSError *)unzipXMLAtTarget:(NSURL *)targetPath forPage:(NSString *)pageID;

@end
