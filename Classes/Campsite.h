// Campsite class builds some location aware functionality (only available on iPhone) on top of CampsiteCore class
//
// Copyright (C) 2010 Matthew Landauer and Katherine Szuminska
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CampsiteCore.h"

@interface Campsite :  CampsiteCore <MKAnnotation>
{
}

- (CLLocation *) location;
- (NSNumber *) distanceFrom:(CLLocation *)location;
- (NSNumber *) bearingFrom:(CLLocation *)location;

@end
