//
//  GTDataImporter.h
//  godtools
//
//  Created by Michael Harrison on 3/18/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTAPI.h"
#import "GTStorage.h"
#import "GTDefaults.h"
#import "RXMLElement.h"

/**
 *  Class used to download content from the God Tools API and save it locally. This is the main class you should use.
 */
@interface GTDataImporter : NSObject\

#warning This is the main class you should use with the apps logic. Start by reading this documentation

/**
 *  Singleton for God Tools Data Importer
 *
 *  @return configured data importer
 */
+ (instancetype)sharedImporter;

/**
 *  Initializes data importer with an API and a Storage class so this class knows where to download and store content.
 *  You can also pass it a default object. If you choose to it will use KVO to initiate an import of data when the default
 *  language(s) and package(s) are updated. Assuming they are new.
 *
 *  @param api      God Tools API class that retrieves content from the God Tools webservice and processes it for use.
 *  @param storage  A Core Data stack used for storing downloaded content.
 *  @param defaults An object that holds the apps current language(s) and package(s). This class will observe changes in this object and initiate requests that are needed.
 *
 *  @return a configured data importer object
 */
- (instancetype)initWithAPI:(GTAPI *)api storage:(GTStorage *)storage defaults:(GTDefaults *)defaults;

/**
 *  Initiates an request to the api for menu data and updates the storage with new values that have been returned.
 *  It is recommended that this is called when the app is opened. When it returns from the background and when the settings button is pressed.
 *  
 *  @note Once the update is completed it will check if the server just reported updated version numbers for any locally stored resources.
 *  If so it will post a notification with the name GTDataImporterNotificationNameUpdateNeeded.
 *  You should listen for this and present the user with the option of updating their resources.
 *  If they select to updated their resources you can use updatePackagesWithNewVersions to complete that action.
 */
- (void)updateMenuInfo;

/**
 *  Downloads new versions of all resources that are out of date according to the meta data downloaded using updateMenuInfo.
 *
 *  @note This method is designed to be used after receiving the "Update Needed" notification from the updateMenuInfo method.
 */
- (void)updatePackagesWithNewVersions;



/////////////////////////Methods for Manual model///////////////////////////
//
//     Methods for manual downloading and updating.
//     You don't have to use these if you provided a GTDefaults object.
//
////////////////////////////////////////////////////////////////////////////


/**
 *  Downloads all resources for the language passed to this method.
 *
 *  @warning language is required. This method will throw and exception if language is nil.
 *
 *  @param language All resources in this language will be downloaded and made available for use.
 */
- (void)downloadPackagesForLanguage:(GTLanguage *)language;

/**
 *  Compares local version number with the version number on the web server. It does this for every resource written in the languages listed in languageCodes.
 *  If the web server is newer it will record it as being in need of an update. If there are one or more resources in
 *  need of an update this method will post a notification with the name GTDataImporterNotificationNameUpdateNeeded.
 *  
 *  @note This method DOES NOT download the version numbers. updateMenuInfo downloads the meta data,
 *  this method just processes the result. This method is also called at the end of updateMenuInfo so only needs to be
 *  called if you want to manually check separate to downloading the meta data with updateMenuInfo.
 *
 *  @warning It will throw an exception if languageCodes is nil or empty.
 *
 *  @param languageCodes An array of the language code for languages you want to check for updates. Cannot be nil or empty.
 */
- (void)checkForPackagesWithNewVersionsForLanguageCodes:(NSArray *)languageCodes;

@end
