#import <UIKit/UIKit.h>
#import "Campsite.h"

@interface CampsiteViewController : UITableViewController {
	Campsite *currentCampsite;
}

@property (nonatomic, retain) Campsite * currentCampsite;

@end
