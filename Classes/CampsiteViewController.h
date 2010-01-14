#import <UIKit/UIKit.h>
#import "Campsite.h"

@interface CampsiteViewController : UIViewController {
	// The current campsite that is being displayed by this controller
	Campsite *campsite;
	BOOL parkClickable;
	CLLocationManager *locationManager;
	UITableView *tableView;
}

@property (nonatomic, retain) Campsite * campsite;
@property BOOL parkClickable;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction) showDirections;

@end
