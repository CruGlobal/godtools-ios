//
//  GTResourceLog.h
//  godtools
//
//  Created by Michael Harrison on 3/19/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTDefaults : NSObject

@property (nonatomic, strong) NSString *currentPackageCode;
@property (nonatomic, strong) NSString *currentLanguageCode;
@property (nonatomic, strong) NSString *currentParallelLanguageCode;

//will be used for choosing  language in the settings menu. This will be the flag to check if the user is choosing a main language or a parallel language
@property (nonatomic, assign) BOOL isChoosingForMainLanguage;
@property (nonatomic) NSNumber *isInTranslatorMode;
@property (nonatomic) NSString *translationDownloadStatus;
@property (nonatomic) NSString *genericApiToken;

@property (nonatomic) NSNumber *languagePromptHasBeenShown;

+ (instancetype)sharedDefaults;
- (NSString *)phonesLanguageCode;

@end
