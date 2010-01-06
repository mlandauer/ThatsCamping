// The table view controller responsible for displaying the list of events, supporting additional functionality:

#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UITableViewController <CLLocationManagerDelegate> {
	
    NSMutableArray *campsitesArray;
    CLLocationManager *locationManager;
}

@property (nonatomic, retain) NSMutableArray *campsitesArray;
@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@end
