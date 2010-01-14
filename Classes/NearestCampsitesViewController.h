// The table view controller responsible for displaying the list of events, supporting additional functionality:

#import <CoreLocation/CoreLocation.h>
#import	<MapKit/MapKit.h>

@interface NearestCampsitesViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, MKMapViewDelegate> {
	
    NSMutableArray *campsitesArray;
    CLLocationManager *locationManager;
	NSManagedObjectContext *managedObjectContext;
	
	UIView *containerView;
	UITableView *tableView;
	MKMapView *mapView;
	
	UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, retain) NSMutableArray *campsitesArray;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (NSString *)distanceInWords:(double)distance;
- (NSString *)bearingInWords:(float)bearing;

- (IBAction)listOrMapChanged:(id)sender;

@end
