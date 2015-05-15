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
#define GTDataImporterNotificationLanguageDownloadProgressMade  @"com.godtoolsapp.GTDataImporter.notifications.languageDownloadProgressMade"
#define GTLanguageViewDataImporterNotificationLanguageDownloadProgressMade  @"com.godtoolsapp.GTDataImporter.notifications.languageViewLanguageDownloadProgressMade"
#define GTDataImporterNotificationLanguageDownloadFinished      @"com.godtoolsapp.GTDataImporter.notifications.languageDownloadFinished"
#define GTLanguageViewDataImporterNotificationLanguageDownloadFinished      @"com.godtoolsapp.GTDataImporter.notifications.languageViewLanguageDownloadFinished"
#define GTLanguageViewDataImporterNotificationLanguageDownloadFailed @"com.godtoolsapp.GTDataImporter.notifications.languageViewLanguageDownloadFailed"
#define GTDataImporterNotificationLanguageDownloadPercentageKey @"com.godtoolsapp.GTDataImporter.notifications.languageDownloadProgressMade.key.percentage"
#define GTDataImporterNotificationNameUpdateNeeded              @"com.godtoolsapp.GTDataImporter.notifications.updateNeeded"

#define GTDataImporterNotificationMenuUpdateFinished @"com.godtoolsapp.GTDataImporter.notifications.updateFinished"
#define GTDataImporterNotificationMenuUpdateStarted @"com.godtoolsapp.GTDataImporter.notifications.updateStarted"

#define GTDataImporterNotificationNewVersionsAvailable @"com.godtoolsapp.GTDataImporter.notifications.newVersionsAvailable"
#define GTDataImporterNotificationNewVersionsAvailableKeyNumberAvailable @"com.godtoolsapp.GTDataImporter.notifications.newVersionsAvailable.key.numberAvailable"
#define GTDataImporterNotificationAuthTokenUpdateStarted @"com.godtoolsapp.GTDataImporter.notifications.authTokenUpdateStarted"
#define GTDataImporterNotificationAuthTokenUpdateSuccessful @"com.godtoolsapp.GTDataImporter.notifications.authTokenUpdateSuccessful"
#define GTDataImporterNotificationAuthTokenUpdateFail @"com.godtoolsapp.GTDataImporter.notifications.authTokenUpdateFailed"

#define GTDataImporterNotificationLanguageDraftsDownloadProgressMade  @"com.godtoolsapp.GTDataImporter.notifications.draftsDownloadProgressMade"
#define GTDataImporterNotificationLanguageDraftsDownloadFinished      @"com.godtoolsapp.GTDataImporter.notifications.draftsDownloadFinished"
#define GTDataImporterNotificationLanguageDraftsDownloadStarted      @"com.godtoolsapp.GTDataImporter.notifications.draftsDownloadStarted"
#define GTDataImporterNotificationLanguageDraftsDownloadPercentageKey @"com.godtoolsapp.GTDataImporter.notifications.draftsDownloadProgressMade.key.percentage"

#define GTDataImporterNotificationCreateDraftStarted    @"com.godtoolsapp.GTDataImporter.notifications.createDraftStarted"
#define GTDataImporterNotificationCreateDraftSuccessful @"com.godtoolsapp.GTDataImporter.notifications.createDraftSuccessful"
#define GTDataImporterNotificationCreateDraftFail       @"com.godtoolsapp.GTDataImporter.notifications.createDraftFail"

#define GTDataImporterNotificationDownloadPageStarted   @"com.godtoolsapp.GTDataImporter.notifications.downloadPageStarted"
#define GTDataImporterNotificationDownloadPageSuccessful @"com.godtoolsapp.GTDataImporter.notifications.downloadPageSuccessful"
#define GTDataImporterNotificationDownloadPageFail       @"com.godtoolsapp.GTDataImporter.notifications.downloadPageFail"


#define GTDataImporterNotificationPublishDraftStarted   @"com.godtoolsapp.GTDataImporter.notifications.publishDraftStarted"
#define GTDataImporterNotificationPublishDraftSuccessful @"com.godtoolsapp.GTDataImporter.notifications.publishDraftSuccessful"
#define GTDataImporterNotificationPublishDraftFail       @"com.godtoolsapp.GTDataImporter.notifications.publishDraftFail"


/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
