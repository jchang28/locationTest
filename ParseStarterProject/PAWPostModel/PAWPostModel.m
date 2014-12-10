//
//  PAWPostModel.m
//  ParseStarterProject
//
//  Created by Jeff@Level3 on 11/21/14.
//
//

#import "PAWPostModel.h"
#import "PAWConstants.h"

/**
 * Private setters to enable setting/getting of properties
 */
@interface PAWPostModel ()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) PFObject *pfObject;
@property (nonatomic, strong) PFUser *pfUser;
@property (nonatomic, strong) NSNumber *pfUserType;

@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end

@implementation PAWPostModel

#pragma mark -
#pragma mark Initializers
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                          andTitle:(NSString *)title
                       andSubtitle:(NSString *)subtitle {
    self = [super init];
    
    if(self) {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subtitle;
    }
    
    return self;
}

- (instancetype)initWithPFObject:(PFObject *)pfObject {
    
    //1.    Ensure we have the fetch pfobject on local device, if not already.
    [pfObject fetchIfNeeded];
    
    //2.    Get the PFGeoPoint within the parse
    PFUser *pfUser = pfObject[PAWParseUserLocationUserKey];
    NSNumber *pfUserType = pfObject[PAWParseUserLocationUserTypeKey];
    PFGeoPoint *pfGeoPoint = pfObject[PAWParseUserLocationLocationKey];

    
    //3.    Construct a Core Locations point based off of the data from cloud.
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(pfGeoPoint.latitude, pfGeoPoint.longitude);
    
    NSString *title = [pfUser username];
    NSString *subtitle = [NSString stringWithFormat:@"User type: %ld", [pfUserType integerValue]];
    
    self = [super init];
    
    if(self) {
        _coordinate = coordinate;
        _title = title;
        _subtitle = subtitle;
        
        _pfObject = pfObject;
        _pfUser = pfUser;
        _pfUserType = pfUserType;
        _pinColor = MKPinAnnotationColorGreen;
    }
    
    return self;
}

#pragma mark -
#pragma mark KVO Obligations?
- (BOOL)isEqual:(id)other {
    if(![other isKindOfClass:[PAWPostModel class]]) {
        return NO;
    }
    
    PAWPostModel *otherPost = (PAWPostModel *)other;

    //1.    If we have parse data object, compare them first.
    if(otherPost.pfObject && self.pfObject) {
        return [otherPost.pfObject.objectId isEqualToString:self.pfObject.objectId];
    }
    
    //2.    If we dont' have parse objects, just use local data to confirm
    //      equalness.
    return ([otherPost.title isEqualToString:self.title] &&
            [otherPost.subtitle isEqualToString:self.subtitle] &&
            [otherPost.pfUserType isEqualToNumber:self.pfUserType] &&
            otherPost.coordinate.longitude == self.coordinate.longitude &&
            otherPost.coordinate.latitude == self.coordinate.latitude);
}

#pragma mark -
#pragma mark Publics - Accessors
- (void)setTitleAndSubtitleOutsideDistance:(BOOL)isOutside {
    if(isOutside) {
        self.title = kPAWWallCantViewPost;
        self.subtitle = nil;
        self.pinColor = MKPinAnnotationColorRed;
    }
    else {
        self.title = self.pfObject[PAWParsePostTextKey];
        
        //Use common name if there is one, othrwise, use the system username.
        self.subtitle = self.pfObject[PAWParsePostUserKey][PAWParsePostNameKey] ?: self.pfObject[PAWParsePostUserKey][PAWParsePostUsernameKey];
        self.pinColor = MKPinAnnotationColorGreen;
    }
}


@end
