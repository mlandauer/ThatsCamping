// The table view controller responsible for displaying the list of events, supporting additional functionality:

#import <CoreLocation/CoreLocation.h>

@interface NearestCampsitesViewController : UITableViewController <CLLocationManagerDelegate, UITableViewDelegate> {
	
    NSMutableArray *campsitesArray;
    CLLocationManager *locationManager;
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSMutableArray *campsitesArray;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	    

- (NSString *)distanceInWords:(double)distance;
- (NSString *)bearingInWords:(float)bearing;
- (void)initialiseStore;

@end
