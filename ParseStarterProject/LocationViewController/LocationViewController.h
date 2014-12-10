//
//  LocationViewController.h
//  ParseStarterProject
//
//  Created by Jeff@Level3 on 11/20/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class LocationViewController;
@class PAWPostModel;

/**
 * Not sure - to be determined.
 */
@protocol LocationViewControllerDelegate <NSObject>

- (void)wantsToPresentSettings:(LocationViewController *)controller;

@end

/**
 * View Controller responsible for displaying a Map Kit map view and
 * sending/receiving user location for Core Location.
 *
 *
 */
@interface LocationViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

#pragma mark -
#pragma Properties
@property (nonatomic, weak) id<LocationViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *userPersonaSegmentControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *seekingPersonalSegmentControl;
@property (strong, nonatomic) IBOutlet UIButton *startStopUpdateLocationButton;

#pragma mark -
#pragma Publics - IBActions
- (IBAction)ibaStartStopLocation:(id)sender;
- (IBAction)ibaCenterMapViewToUserLocation:(id)sender;



@end

/**
 * Used for TBD
 */
@protocol LocationViewControllerHighlight <NSObject>

- (void)highlightCellForPost:(PAWPostModel *)post;
- (void)unhighlightCellForPost:(PAWPostModel *)post;

@end
