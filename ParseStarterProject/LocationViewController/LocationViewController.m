//
//  LocationViewController.m
//  ParseStarterProject
//
//  Created by Jeff@Level3 on 11/20/14.
//
//

#import "LocationViewController.h"
#import "PAWConstants.h"
#import "PAWPostModel.h"

//To be implemented....
//#import WallPostCreateViewController
//#import WallPostTableViewController


/**
 * Private implementations
 *
 * Privately conform to the other 2 delegates - very fancy...
 * PAWWallPostsTableViewControllerDataSource,
 * PAWWallPostCreateViewControllerDataSource,
 * Will fill them in once I get to it...
 */
@interface LocationViewController ()

@property (nonatomic, assign) BOOL updatingLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

//Very interesting, the first time I' suing a circle overlay...
@property (nonatomic, strong) MKCircle *circleOverlay;

//No idea what the annotations array does...
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, assign) BOOL mapPinPlaced;
@property (nonatomic, assign) BOOL mapPannedSinceLocationUpdate;

//My own buckets of locations for sorting out each update on the map.
@property (nonatomic, strong) NSMutableArray *displayedModels;



//To be implemented...
//@property (nonatomic, strong) WallPostTableViewController *wallPostsTableViewController;

@property (nonatomic, strong)NSMutableArray *allPosts;

@end

@implementation LocationViewController

#pragma mark -
#pragma mark Initializers
- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if(self) {
        self.title = @"Location View";
        
        _annotations = [[NSMutableArray alloc] initWithCapacity:10];
        _allPosts = [[NSMutableArray alloc] initWithCapacity:10];
        _displayedModels = [[NSMutableArray alloc] initWithCapacity:10];
        
        //[ ]
        //1.    Setup to receive notifications.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_locationSavedNotificationHandler:)
                                                     name:PAWLocationSavedNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark Custom getter and setters
//Note that custom getter and setters should use raw pointers.
- (CLLocationManager *)locationManager {
    if(_locationManager) {
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //A threashold for updating/firing to the delegate.
    _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    
    [_locationManager requestWhenInUseAuthorization];
    
    return _locationManager;
}

//Custom set location - this will trigger some stuff...
- (void)setCurrentLocation:(CLLocation *)currentLocation {
    
    //0.    Check if we are using the same current location, if so, no need
    //      to cause a raucous.
    if(self.currentLocation == currentLocation) {
        return;
    }
    
    //1.    Set the current one and send off a notification that the location
    //      has changed; as implied we have a different location object
    //      due to the designated delta change of X meters.
    _currentLocation = currentLocation;
    
    //[ ]
    /**
     * This is for the table view -, not yet in
     * come back to it later...
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PAWCurrentLocationDidChangeNotification
                                                            object:nil
                                                          userInfo:@{ kPAWLocationKey : currentLocation }];
    });
     */
    
    
    //2.    Recenter the map, if not previously moved based on the new location
    //      Not 100% sure on what the filter distance means, is it a percentage?
    //      Will understand more when I've looked at it at its intial setting
    //      in the app delegate as a persistant user setting.
    CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:PAWUserDefaultsFilterDistanceKey];
    
    if(!self.mapPannedSinceLocationUpdate) {
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, filterDistance * 2.0f, filterDistance * 2.0f);
        
        //Not sure why the save off on the panned value..?
        BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
        [self.mapView setRegion:newRegion
                       animated:YES];
        self.mapPannedSinceLocationUpdate = oldMapPannedValue;
    }
    
    //If already moved, not updating yet...
    
    //3.    Update the drawing of the overlaw.
    if(self.circleOverlay) {
        [self.mapView removeOverlay:self.circleOverlay];
        self.circleOverlay = nil;
    }
    
    //Seems like the filter distance is the radius - understand later..
    self.circleOverlay = [MKCircle circleWithCenterCoordinate:self.currentLocation.coordinate
                                                       radius:filterDistance];
    [self.mapView addOverlay:self.circleOverlay];
    
    //[ ] - To do - Update map with close by pins, retrieved from Parse?
    
    //[ ] - To do - Update existing pins to reflect any changes in the filter distance    
}

#pragma mark -
#pragma mark Dealloc
- (void)dealloc {
    
    //0.    Stop updating location.
    [self.locationManager stopUpdatingLocation];
    self.mapView.showsUserLocation = NO;
    
    //1.    Unregister from notification center.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PAWLocationSavedNotification
                                                  object:nil];
}

#pragma mark -
#pragma mark Overrides


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //1.    Load a Parse powered table view to display the locations...
    //...
    
    //2.    Add navigation buttons for access.
    //
    
    //3.    Update the map view with default coordinations and range?
    //      This sets up a point and zoom level using well know values
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.33249f, -122.029095f), MKCoordinateSpanMake(0.008516f, 0.021801f));
    self.mapPannedSinceLocationUpdate = NO;
    
    //Moved to standard start / stop
    //self.mapView.showsUserLocation = YES;
    
    
    //4.    Start updating map location, standardlly...whatever that means.
    //      The difference between _startStandardUpdates vs locationManagerUpdate
    //      is in addition to getting updates, it will save off a copy of the
    //      current user location to the self.currentLocation.
    //[self _startStandardUpdates];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //1.    Start using the location manager to get location telemetry
    //[self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //1.    Stop updating location telemetry to save energy as the view
    //      won't be using it.
    [self.locationManager stopUpdatingLocation];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark IBActions
- (IBAction)ibaStartStopLocation:(id)sender {
    
    
    
    if(self.updatingLocation) {
        [self _stopStandardUpdates];
    }
    else {
        [self _startStandardUpdates];
    }
}

- (IBAction)ibaCenterMapViewToUserLocation:(id)sender {
    CLLocationCoordinate2D current2DLocation = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
    [self.mapView setCenterCoordinate:current2DLocation
                             animated:YES];
}


- (IBAction)ibaUserPersonaSegmentChanged:(id)sender {
    NSLog(@"User persona index is:[%ld].", (long)self.userPersonaSegmentControl.selectedSegmentIndex);
    
    if(self.userPersonaSegmentControl.selectedSegmentIndex == self.seekingPersonalSegmentControl.selectedSegmentIndex) {
        NSInteger nextSeekingIndex = self.userPersonaSegmentControl.selectedSegmentIndex;
        nextSeekingIndex = ++nextSeekingIndex % 4;
        
        [self.seekingPersonalSegmentControl setSelectedSegmentIndex:nextSeekingIndex];
    }
}

- (IBAction)seekingPersonaSegmentChanged:(id)sender {
    NSLog(@"Seeking persona index is [%ld].", (long)self.seekingPersonalSegmentControl.selectedSegmentIndex);
    
    if(self.seekingPersonalSegmentControl.selectedSegmentIndex == self.userPersonaSegmentControl.selectedSegmentIndex) {
        NSInteger nextUserIndex = self.seekingPersonalSegmentControl.selectedSegmentIndex;
        nextUserIndex = ++nextUserIndex % 4;
        
        [self.userPersonaSegmentControl setSelectedSegmentIndex:nextUserIndex];
    }
}


#pragma mark -
#pragma mark Privates - Map related
/**
 * Seems like it only gets the initial update?
 * Subsequent updates by the location manager will need to be triggered
 * via delegates or notifications?
 *
 * NOTE that the self.currentLocation = currentLocation triggers the overriden
 * setter, which triggers a notification, which is also handled here in this
 * view controller.
 * The handler I guess will be responsible for updating the pins and map view...
 * etc...
 *
 *
 */
- (void)_startStandardUpdates {
    [self.locationManager startUpdatingLocation];
    self.updatingLocation = YES;
    self.mapView.showsUserLocation = YES;
    [self _updateStartStopButtonLabel:self.updatingLocation];
    
    CLLocation *currentLocation = self.locationManager.location;
    if(currentLocation) {
        self.currentLocation = currentLocation;
    }
}

- (void)_stopStandardUpdates {
    [self.locationManager stopUpdatingLocation];
    self.updatingLocation = NO;
    self.mapView.showsUserLocation = NO;
    [self _updateStartStopButtonLabel:self.updatingLocation];
}

- (void)_updateStartStopButtonLabel:(BOOL)updatingLocationStatus {
    if(updatingLocationStatus) {
        [self.startStopUpdateLocationButton setTitle:@"Stop"
                                            forState:UIControlStateNormal];
        return;
    }
    
    [self.startStopUpdateLocationButton setTitle:@"Start"
                                        forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Private - Posting of location to Parse
- (void)_saveLoctionToParse:(CLLocation *)location {

    //0.    Serailize a parse objec to store on parse:
    
    //1.    Create a PFGeoPoint based on the new location, not sure
    //      why the example uses a longitude and latitude initializer.
    PFGeoPoint *parseLocation = [PFGeoPoint geoPointWithLocation:location];
    
    //2.    Get user location.
    PFUser *postingUser = [PFUser currentUser];
    
    //3.    Create other metadata to save into parse.
    //      >User Type
    //      >
    PFObject *parseLocationData = [PFObject objectWithClassName:PAWParseUserLocationClassName];
    parseLocationData[PAWParseUserLocationLocationKey] = parseLocation;
    parseLocationData[PAWParseUserLocationUserKey] = postingUser;
    parseLocationData[PAWParseUserLocationUserTypeKey] = [NSNumber numberWithInteger:self.userPersonaSegmentControl.selectedSegmentIndex];
    
    PFACL *publicReadOnlyACL = [PFACL ACL];
    [publicReadOnlyACL setPublicReadAccess:YES];
    [publicReadOnlyACL setPublicWriteAccess:NO];
    parseLocationData.ACL = publicReadOnlyACL;
    
    [parseLocationData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error) {
            NSLog(@"Failed to save location to Parse -  Due to error[%@].", error);
            return;
        }
        
        if(succeeded) {
            NSLog(@"Saved location to Parse[%@]", parseLocationData);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:PAWLocationSavedNotification
                                                                    object:nil];
            });
        }
        else {
            NSLog(@"Failed to save - Did not succed.");
        }
        
    }];
}

//Triggered by the notification, to fetch Parse for locations, and update
//the map view with new locations.
- (void)_fetchLocationNearMeFromParse {
    PFQuery *locationQuery = [PFQuery queryWithClassName:PAWParseUserLocationClassName];
    
    //Not sure how the cache works yet.
    if([self.displayedModels count] == 0) {
        locationQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    }
    
    //1.    Get the current location as a geopoint to help us get only
    //      locations near us.
    PFGeoPoint *currentLocationAsGeoPoint = [PFGeoPoint geoPointWithLocation:self.currentLocation];
    
    //2.    Get location near me within 5.0 miles.
    //      - Include user
    //      - Include user type
    //      - Limit retrieve points to 10.
    [locationQuery whereKey:PAWParseUserLocationLocationKey
               nearGeoPoint:currentLocationAsGeoPoint
                withinMiles:PAWWallPostMaximumSearchDistanceMiles];
    [locationQuery includeKey:PAWParseUserLocationUserKey];
    //[locationQuery includeKey:PAWParseUserLocationUserTypeKey];

    //Does not limit yet, lets see what happens.
    locationQuery.limit = PAWUserLocationSearchDefaultLimit;
    
    [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error querying for user locations[%@].", error);
            
            return;
        }
        
        NSMutableArray *cachedObjectsFromParseAsModels = [[NSMutableArray alloc] initWithCapacity:PAWUserLocationSearchDefaultLimit];
        NSMutableArray *newLocationsFromParse = [[NSMutableArray alloc] initWithCapacity:PAWUserLocationSearchDefaultLimit];
        NSMutableArray *expiredLocationsToRemove = [[NSMutableArray alloc] initWithCapacity:PAWUserLocationSearchDefaultLimit];

        //1.    Get a list of new locations from parse (not currently displayed).
        for(PFObject *objectFetchedFromParse in objects) {
            
            //a.    Convert parse objects into models specific for our app
            //      presentation.
            PAWPostModel *parseObjectAsPostModel = [[PAWPostModel alloc] initWithPFObject:objectFetchedFromParse];
            
            //b.    Save off the converted objects for later use.
            [cachedObjectsFromParseAsModels addObject:parseObjectAsPostModel];
            

            if(![self.displayedModels containsObject:parseObjectAsPostModel])
                [newLocationsFromParse addObject:parseObjectAsPostModel];
        }
        
        //2.    Get a list of expired locations
        for(PAWPostModel *displayedModel in self.displayedModels) {
            if(![cachedObjectsFromParseAsModels containsObject:displayedModel]) {
                [expiredLocationsToRemove addObject:displayedModel];
            }
        }
        
        //3.    Update the map view.
        //[self _updateMapViewWithNewLocations:newLocationsFromParse andExpiredLocations:expiredLocationsToRemove];
        for(PAWPostModel *newLocation in newLocationsFromParse) {
            newLocation.animatesDrop = YES;
        }
        [self.mapView removeAnnotations:expiredLocationsToRemove];
        [self.mapView addAnnotations:newLocationsFromParse];
        [self.displayedModels removeObjectsInArray:expiredLocationsToRemove];
        [self.displayedModels addObjectsFromArray:newLocationsFromParse];

    }];
}

- (void)_updateMapViewWithNewLocations:(NSArray *)newLocations
                   andExpiredLocations:(NSArray *)expiredLocations {
//    for(PAWPostModel *newLocation in newLocations) {
//        
//        //1.    Additional business logic.
//        
//        //2.    Set drop, not sure what this is about yet...
//        newLocation.animatesDrop = YES;
//    }
    
    //1.    Update the map view with new locations and remove expired locations.
    [self.mapView removeAnnotations:expiredLocations];
    [self.mapView addAnnotations:newLocations];
    
    //2.    Update our own record of what is displayed for comparison in the
    //      next udpate.
    [self.displayedModels addObjectsFromArray:newLocations];
    [self.displayedModels removeObjectsInArray:expiredLocations];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate obligations
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch(status) {
        case kCLAuthorizationStatusAuthorized: {
            NSLog(@"kCLAuthorizationStatusAuthorized");
            
            [self _startStandardUpdates];
            //[self.locationManager startUpdatingLocation];
            
            //[ ] - To do, additional ui updates to correspond to this auth status.
        }
            break;
        case kCLAuthorizationStatusDenied: {
            NSLog(@"kCLAuthorizationStatusDenied");
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please enable location services for this app to function correctly."
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [alertView show];
        }
            break;
            
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"kCLAuthorizationStatusNotDetermined");
            
        }
            break;
            
        case kCLAuthorizationStatusRestricted: {
            NSLog(@"kCLAuthorizationStatusRestricted");
            
        }
            break;
    }
}

/**
 * Note that this delegate function is deprecated, use the one
 * with the arrays in future scenarios - for now, just use this one for demo
 * purposes.
 * -jchang
 */
- (void)locationManager:(CLLocationManager *)manager
didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    //0.    Saves the current location.
    self.currentLocation = newLocation;
    
    //1.    Saves the old location to parse.
    [self _saveLoctionToParse:oldLocation];
}

/**
 * Error checking for nicecities...
 * Because we are civilized folk.
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"Error:[%@]", [error description]);
    
    if(error.code == kCLErrorDenied) {
        NSLog(@"kCLErrorDenied");
        [self.locationManager stopUpdatingLocation];
        
        return;
    }
    
    if(error.code == kCLErrorLocationUnknown) {
        NSLog(@"kCLErrorLocationUnknown");
        
        return;
    }
    
    //All other type of errors:
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location."
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

#pragma mark -
#pragma mark MKMapViewDelegate obligations
/**
 *
 * Not sure exactly why the check on the overlay type, I can only assume that
 * it is very possible on the map, there are/can be multiple overlays in play,
 * and you only want to do work on your own specific overlay (that you may or
 * may not override).
 *
 * I'm assuming that this gets called multiple times as the map is updated???
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay {
    NSLog(@"mapView:rendererForOverlay Entered.");
    
    //We are only interested in circle overlays - I think...
    if([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRender = [[MKCircleRenderer alloc] initWithCircle:self.circleOverlay];
        
        [circleRender setFillColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.2f]];
        [circleRender setStrokeColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.7f]];
        [circleRender setLineWidth:1.0f];
        
        return circleRender;
    }
    
    return nil;
}

/**
 * Handles 2 kind of annotation, seems like returing nil will let the system
 * handle it.
 *
 * I'm guessing this is essentially the  a pin.
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    
    NSLog(@"mapView:viewForAnnotation Entered...");
    //1.    User Location annotation
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        //From the apple documentation:
        //"...nil if you want to dispaly a standard annotation view."
        NSLog(@"MKUserLocation annotation requested...");
        return nil;
    }
    
    //2.    Our custom annotation view that represents our posts....
    //      might need to comeback to it later.
    static NSString *pinIdentifier = @"CustomPinAnnotation";
    if([annotation isKindOfClass:[PAWPostModel class]]) {
        
        //1.    Reuse existing views if possible.
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        
        if(!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:pinIdentifier];
        }
        else {
            pinView.annotation = annotation;
        }
        
        pinView.pinColor = [(PAWPostModel *)annotation pinColor];
        pinView.animatesDrop = [(PAWPostModel *)annotation animatesDrop];
        pinView.canShowCallout = YES;
        
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView
didSelectAnnotationView:(MKAnnotationView *)view {
    
    NSLog(@"mapView:didSelectAnnotationView entered.");
    
    id<MKAnnotation> annotation = [view annotation];
    
    if([annotation isKindOfClass:[PAWPostModel class]]) {
        PAWPostModel *post = (PAWPostModel *)[view annotation];
        
        //[ ] - To do later...
        //highlight the table view elements
        //which we'll get ot later.
    }
    //If user location pin is touched, center the map.
    //ahh, so the annotation is the pin itself...
    else if([annotation isKindOfClass:[MKUserLocation class]]) {
        CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:PAWUserDefaultsFilterDistanceKey];
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, filterDistance * 2.0f, filterDistance * 2.0f);
        
        [self.mapView setRegion:newRegion
                       animated:YES];
        self.mapPannedSinceLocationUpdate = NO;
    }
}

- (void)mapView:(MKMapView *)mapView
didDeselectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"mapView:didDeselectAnnotationView entered.");
    id<MKAnnotation> annotation = [view annotation];
    
    if([annotation isKindOfClass:[PAWPostModel class]]) {
        //[ ] - To do later, unhighlights the table view...
        
    }
}

- (void)mapView:(MKMapView *)mapView
regionWillChangeAnimated:(BOOL)animated {
    NSLog(@"mapView:regionWillChangeAnimated entered.");
    //Not sure what this flag will be used yet..
    self.mapPannedSinceLocationUpdate = YES;
}


#pragma mark -
#pragma mark NSNotification handlers
- (void)_locationSavedNotificationHandler:(NSNotification *)notification {
    [self _fetchLocationNearMeFromParse];
}

@end
