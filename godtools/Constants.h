//
//  Constants.h
//  godtools
//
//  Created by Claudine Bael on 11/13/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#ifndef godtools_Constants_h
#define godtools_Constants_h

/*
 *  Notifications Constants
 */

//Data Importer
#define LanguageDownloadStarted @"com.godtoolsapp.GTDataImporter.notifications.draftsDownloadStarted"
#define LanguageDownloadProgressMade  @"com.godtoolsapp.GTDataImporter.notifications.languageDownloadProgressMade"
#define LanguageDownloadFinished      @"com.godtoolsapp.GTDataImporter.notifications.languageDownloadFinished"
#define LanguageDownloadPercentageKey @"com.godtoolsapp.GTDataImporter.notifications.languageDownloadProgressMade.key.percentage"
#define LanguageDownloadFailed @"com.godtoolsapp.GTDataImporter.notifications.draftsDownloadFailed"

#define UpdateNeeded              @"com.godtoolsapp.GTDataImporter.notifications.updateNeeded"

#define MenuUpdateFinished @"com.godtoolsapp.GTDataImporter.notifications.menuUpdateFinished"
#define MenuUpdateStarted @"com.godtoolsapp.GTDataImporter.notifications.menuUpdateStarted"

#define NewVersionsAvailable @"com.godtoolsapp.GTDataImporter.notifications.newVersionsAvailable"
#define UpdateStarted @"com.godtoolsapp.GTDataImporter.notifications.updateStarted"
#define UpdateFinished @"com.godtoolsapp.GTDataImporter.notifications.updateFinished"
#define UpdateFailed @"com.godtoolsapp.GTDataImporter.notifications.updateFailed"
#define UpdateCancelled @"com.godtoolsapp.GTDataImporter.notifications.updateCancelled"
#define UpdateCancelledForLanguage @"com.godtoolsapp.GTDataImporter.notifications.updateCancelledForLanguage"
#define UpdateKeyLanguage @"com.godtoolsapp.GTDataImporter.notifications.update.key.language"

#define PackageKeyPackage @"com.godtoolsapp.GTDataImporter.notifications.package.key.package"
#define KeyLanguage @"com.godtoolsapp.GTDataImporter.notifications.key.language"
#define PackageXmlDownloadProgressMade @"com.godtoolsapp.GTDataImporter.notifications.packageXmlDownloadProgressMade"
#define PackageXmlDownloadFinished @"com.godtoolsapp.GTDataImporter.notifications.packageXmlDownloadFinished"
#define PackageXmlDownloadFailed @"com.godtoolsapp.GTDataImporter.notifications.packageXmlDownloadFailed"
#define MajorUpdateProgressMade @"com.godtoolsapp.GTDataImporter.notifications.majorUpdateProgressMade"
#define MajorUpdateFinished @"com.godtoolsapp.GTDataImporter.notifications.majorUpdateFinished"
#define MajorUpdateFailed @"com.godtoolsapp.GTDataImporter.notifications.majorUpdateFailure"
#define PackageDownloadProgressMade @"com.godtoolsapp.GTDataImporter.notifications.packageDownloadProgressMade"
#define PackageDownloadFinished @"com.godtoolsapp.GTDataImporter.notifications.packageDownloadFinished"
#define PackageDownloadFailed @"com.godtoolsapp.GTDataImporter.notifications.packageDownloadFailure"

#define NewVersionsAvailableKeyNumberAvailable @"com.godtoolsapp.GTDataImporter.notifications.newVersionsAvailable.key.numberAvailable"
#define AuthTokenUpdateStarted @"com.godtoolsapp.GTDataImporter.notifications.authTokenUpdateStarted"
#define AuthTokenUpdateSuccessful @"com.godtoolsapp.GTDataImporter.notifications.authTokenUpdateSuccessful"
#define AuthTokenUpdateFail @"com.godtoolsapp.GTDataImporter.notifications.authTokenUpdateFailed"

#define CreateDraftStarted    @"com.godtoolsapp.GTDataImporter.notifications.createDraftStarted"
#define CreateDraftSuccessful @"com.godtoolsapp.GTDataImporter.notifications.createDraftSuccessful"
#define CreateDraftFail       @"com.godtoolsapp.GTDataImporter.notifications.createDraftFail"

#define DownloadPageStarted   @"com.godtoolsapp.GTDataImporter.notifications.downloadPageStarted"
#define DownloadPageSuccessful @"com.godtoolsapp.GTDataImporter.notifications.downloadPageSuccessful"
#define DownloadPageFail       @"com.godtoolsapp.GTDataImporter.notifications.downloadPageFail"

#define PublishDraftStarted   @"com.godtoolsapp.GTDataImporter.notifications.publishDraftStarted"
#define PublishDraftSuccessful @"com.godtoolsapp.GTDataImporter.notifications.publishDraftSuccessful"
#define PublishDraftFail       @"com.godtoolsapp.GTDataImporter.notifications.publishDraftFail"


/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
