#import <UIKit/UIKit.h>
#import "Campsite.h"

@interface CampsiteViewController : UITableViewController {
	// The current campsite that is being displayed by this controller
	Campsite *campsite;
	BOOL parkClickable;
	CLLocationManager *locationManager;
}

@property (nonatomic, retain) Campsite * campsite;
@property BOOL parkClickable;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end
