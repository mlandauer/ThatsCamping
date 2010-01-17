#import <UIKit/UIKit.h>
#import "Campsite.h"

@interface CampsiteViewController : UIViewController {
	// The current campsite that is being displayed by this controller
	Campsite *campsite;
	BOOL parkClickable;
	CLLocationManager *locationManager;
	UITableView *tableView;
	UIBarButtonItem *directionsButton;
}

@property (nonatomic, retain) Campsite * campsite;
@property BOOL parkClickable;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *directionsButton;

- (IBAction) showDirections;
- (NSArray *)facilitiesFields;
- (NSArray *)accessFields;
- (NSString *) textFromList:(NSArray *)list joinWord:(NSString *)joinWord;

int const NAMES_SECTION_INDEX;
int const FACILITIES_SECTION_INDEX;
int const ACCESS_SECTION_INDEX;

@end
