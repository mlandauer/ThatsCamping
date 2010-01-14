#import <UIKit/UIKit.h>
#import "Campsite.h"

@interface CampsiteViewController : UITableViewController {
	// The current campsite that is being displayed by this controller
	Campsite *campsite;
	BOOL parkClickable;
	CLLocationCoordinate2D currentCoordinate;
}

@property (nonatomic, retain) Campsite * campsite;
@property BOOL parkClickable;
@property CLLocationCoordinate2D currentCoordinate;

@end
