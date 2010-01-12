#import <UIKit/UIKit.h>
#import "Park.h"

@interface ParkViewController : UITableViewController {
	Park *currentPark;
	NSArray *campsites;
}

@property (nonatomic, retain) Park * currentPark;
@property (nonatomic, retain) NSArray *campsites;

@end
