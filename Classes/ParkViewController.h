#import <UIKit/UIKit.h>
#import "Park.h"
#import <CoreLocation/CoreLocation.h>

@interface ParkViewController : UITableViewController {
	Park *currentPark;
	NSArray *campsites;
	CLLocationManager *locationManager;
}

@property (nonatomic, retain) Park * currentPark;
@property (nonatomic, retain) NSArray *campsites;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end
