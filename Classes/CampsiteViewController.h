#import <UIKit/UIKit.h>
#import "Campsite.h"

@interface CampsiteViewController : UITableViewController {
	Campsite *currentCampsite;
	BOOL parkClickable;
}

@property (nonatomic, retain) Campsite * currentCampsite;
@property BOOL parkClickable;

@end
