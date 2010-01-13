#import <UIKit/UIKit.h>
#import "Campsite.h"

@interface CampsiteViewController : UITableViewController {
	// The current campsite that is being displayed by this controller
	Campsite *campsite;
	BOOL parkClickable;
}

@property (nonatomic, retain) Campsite * campsite;
@property BOOL parkClickable;

@end
