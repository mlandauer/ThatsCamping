// The table view controller responsible for displaying the list of events, supporting additional functionality:

#import "RootViewController.h"
#import "ThatsCampingAppDelegate.h"
#import "Campsite.h"


@implementation RootViewController


@synthesize campsitesArray, locationManager;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Set the title.
    self.title = @"Campsites near you";
    
	// Start the location manager.
	[[self locationManager] startUpdatingLocation];

	// TODO: Start a spinner to say that we are updating location
}


- (void)viewDidUnload {
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
	self.campsitesArray = nil;
	self.locationManager = nil;
}


#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Only one section.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// As many rows as there are obects in the events array.
    return [campsitesArray count];
}

// Returns a nicely formatted version of the distance as a string
// TODO: Should implement this as a custom formatter (i.e. derived from NSFormatter)
- (NSString *)distanceInWords:(NSNumber *)distance {
	static NSNumberFormatter *numberFormatter = nil;
	if (numberFormatter == nil) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:3];
	}

	NSString *string = [numberFormatter stringFromNumber:distance];
	return string;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		UITableViewCellStyleValue1;
    }
    
	// Get the campsite corresponding to the current index path and configure the table view cell.
	Campsite *campsite = (Campsite *)[campsitesArray objectAtIndex:indexPath.row];
	
	cell.detailTextLabel.text = [campsite name];
	
	NSString *string = [self distanceInWords:[campsite distance]];
    cell.textLabel.text = string;
    
	return cell;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	// If we are running on the simulator provide a fixed location
	#if TARGET_IPHONE_SIMULATOR
	newLocation = [[CLLocation alloc] initWithLatitude:-33.772609 longitude:150.624263];
	#endif

	// Now that we know the location update the list of campsites
	NSMutableArray *mutableFetchResults = [NSMutableArray arrayWithCapacity:3];
	
	Campsite *campsite;
	campsite = [[Campsite alloc] init];
	[campsite setName:@"Perrys Lookdown"];
	[campsite setLatitude:[NSNumber numberWithDouble:-33.598333]];
	[campsite setLongitude:[NSNumber numberWithDouble:150.351111]];
	[mutableFetchResults addObject:campsite];
	[campsite release];
	
	campsite = [[Campsite alloc] init];
	[campsite setName:@"Euroka Clearing"];
	[campsite setLatitude:[NSNumber numberWithDouble:-33.798333]];
	[campsite setLongitude:[NSNumber numberWithDouble:150.617778]];
	[mutableFetchResults addObject:campsite];
	[campsite release];
	
	campsite = [[Campsite alloc] init];
	[campsite setName:@"Murphys Glen"];
	[campsite setLatitude:[NSNumber numberWithDouble:-33.765]];
	[campsite setLongitude:[NSNumber numberWithDouble:150.501111]];
	[mutableFetchResults addObject:campsite];
	[campsite release];
	
	// Loop through the campsites and calculate the distance from our current location
	for (int i=0; i < [mutableFetchResults count]; i++) {
		Campsite *campsite = [mutableFetchResults objectAtIndex:i];
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[[campsite latitude] doubleValue] longitude:[[campsite longitude] doubleValue]];
		[campsite setDistance:[NSNumber numberWithDouble:[newLocation getDistanceFrom:loc]]];
		[loc release];
	}
	
	// Set self's events array to the mutable array, then clean up.
	[self setCampsitesArray:mutableFetchResults];
	
	// Now show the new data
	[[self tableView] reloadData];
}

#pragma mark -
#pragma mark Location manager

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[campsitesArray release];
    [locationManager release];
    [super dealloc];
}


@end

