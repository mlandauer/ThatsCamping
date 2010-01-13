// The table view controller responsible for displaying the list of events, supporting additional functionality:

#import <CoreLocation/CoreLocation.h>

@interface NearestCampsitesViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate> {
	
    NSMutableArray *campsitesArray;
    CLLocationManager *locationManager;
	NSManagedObjectContext *managedObjectContext;
	UITableView *tableView;
}

@property (nonatomic, retain) NSMutableArray *campsitesArray;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	    
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (NSString *)distanceInWords:(double)distance;
- (NSString *)bearingInWords:(float)bearing;

@end
