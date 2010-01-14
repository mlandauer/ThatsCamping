#import <MapKit/MapKit.h>
#import "NearestCampsitesViewController.h"

@interface MyAnnotationView : MKPinAnnotationView {
	NearestCampsitesViewController *delegate;
}

@property (nonatomic, retain) NearestCampsitesViewController *delegate;

@end
