#import <UIKit/UIKit.h>
#import "Park.h"
#import <CoreLocation/CoreLocation.h>

@interface ParkViewController : UITableViewController {
	Park *currentPark;
	NSArray *campsites;
	CLLocationCoordinate2D currentCoordinate;
}

@property (nonatomic, retain) Park * currentPark;
@property (nonatomic, retain) NSArray *campsites;
@property CLLocationCoordinate2D currentCoordinate;

@end
