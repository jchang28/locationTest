//
//  PAWPostModel.h
//  ParseStarterProject
//
//  Created by Jeff@Level3 on 11/21/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

/**
 * Model of data storage - maybe locally on the device used to store map related 
 * information for the presentation.
 *
 * Note the assign/readonly, copy/readonly getter/setters - these are for public
 * as I've learned that you can redefine them in the private implementation
 * (class extentions) to be class internal writeable.
 *
 * Simulating the C++/Java public/private methods.
 *
 * WTF is the "instancetype" keyword, I have no idea what it is...
 */
@interface PAWPostModel : NSObject <MKAnnotation>

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;

@property (nonatomic, strong, readonly) NSNumber *pfUserType;
@property (nonatomic, strong, readonly) PFObject *pfObject;
@property (nonatomic, strong, readonly) PFUser *pfUser;
@property (nonatomic, assign) BOOL animatesDrop;
@property (nonatomic, assign, readonly) MKPinAnnotationColor pinColor;

#pragma mark -
#pragma mark Initializers
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                          andTitle:(NSString *)title
                       andSubtitle:(NSString *)subtitle;

- (instancetype)initWithPFObject:(PFObject *)pfObject;

#pragma mark -
#pragma mark Public - Getters and setters
- (void)setTitleAndSubtitleOutsideDistance:(BOOL)isOutside;


@end
