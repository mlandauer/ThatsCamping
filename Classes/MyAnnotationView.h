//
// Copyright (C) 2010 Matthew Landauer and Katherine Szuminska
//

#import <MapKit/MapKit.h>
#import "NearestCampsitesViewController.h"

@interface MyAnnotationView : MKPinAnnotationView {
	NearestCampsitesViewController *delegate;
}

@property (nonatomic, retain) NearestCampsitesViewController *delegate;

@end
