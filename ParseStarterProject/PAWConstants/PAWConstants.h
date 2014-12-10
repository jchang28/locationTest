//
//  PAWConstants.h
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#ifndef Anywall_PAWConstants_h
#define Anywall_PAWConstants_h

static double PAWFeetToMeters(double feet) {
    return feet * 0.3048;
}

static double PAWMetersToFeet(double meters) {
    return meters * 3.281;
}

static double PAWMetersToKilometers(double meters) {
    return meters / 1000.0;
}

static double const PAWDefaultFilterDistance = 1000.0;
static double const PAWWallPostMaximumSearchDistance = 100.0; // Value in kilometers
static double const PAWWallPostMaximumSearchDistanceMiles = 5.0; //Value in miles

static NSUInteger const PAWWallPostsSearchDefaultLimit = 20; // Query limit for pins and tableviewcells
static NSUInteger const PAWUserLocationSearchDefaultLimit = 10;

// Parse API key constants:
//username is the system user name.
//name is most likely the common name of a person.
static NSString * const PAWParsePostsClassName = @"Posts";
static NSString * const PAWParseUserLocationClassName = @"UserLocations";

static NSString * const PAWParsePostUserKey = @"user";
static NSString * const PAWParsePostUsernameKey = @"username";
static NSString * const PAWParsePostTextKey = @"text";
static NSString * const PAWParsePostLocationKey = @"location";
static NSString * const PAWParsePostNameKey = @"name";

static NSString * const PAWParseUserLocationLocationKey = @"lcation";
static NSString * const PAWParseUserLocationUserKey = @"user";
static NSString * const PAWParseUserLocationUserTypeKey = @"userType";


// NSNotification userInfo keys:
static NSString * const kPAWFilterDistanceKey = @"filterDistance";
static NSString * const kPAWLocationKey = @"location";

// Notification names:
static NSString * const PAWFilterDistanceDidChangeNotification = @"PAWFilterDistanceDidChangeNotification";
static NSString * const PAWCurrentLocationDidChangeNotification = @"PAWCurrentLocationDidChangeNotification";
static NSString * const PAWPostCreatedNotification = @"PAWPostCreatedNotification";
static NSString * const PAWLocationSavedNotification = @"PAWLocationSavedNotification";

// UI strings:
static NSString * const kPAWWallCantViewPost = @"Can’t view post! Get closer.";

// NSUserDefaults
static NSString * const PAWUserDefaultsFilterDistanceKey = @"filterDistance";

typedef double PAWLocationAccuracy;

#endif // Anywall_PAWConstants_h
