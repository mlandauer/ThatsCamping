// The table view controller responsible for displaying the list of events, supporting additional functionality:

#import "RootViewController.h"
#import "ThatsCampingAppDelegate.h"
#import "Campsite.h"
#import "Park.h"

@implementation RootViewController


@synthesize campsitesArray, locationManager, managedObjectContext;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Set the title.
    self.title = @"Campsites near you";
    
	// Start the location manager.
	[[self locationManager] startUpdatingLocation];
	// TODO: Start a spinner to say that we are updating location

	[self initialiseStore];
	
	// Fetch the campsites in order of distance (but only for those with distance set)
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"distance != NULL"];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];

	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
	}	

	[self setCampsitesArray:mutableFetchResults];
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
- (NSString *)distanceInWords:(double)distance {
	static NSNumberFormatter *numberFormatter = nil;
	if (numberFormatter == nil) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:0];
	}

	NSString *units;
	if (distance >= 1000.0) {
		distance /= 1000;
		units = @"km";
	}
	else {
		units = @"m";
		// TODO: Change the number formatting for distances displayed in metres
	}

	NSString *string = [NSString stringWithFormat:@"%@ %@", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:distance]], units];
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
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", [campsite name], [[campsite park] name]];
	cell.detailTextLabel.numberOfLines = 2;
	
	NSString *string = [self distanceInWords:[[campsite distance] doubleValue]];
    cell.textLabel.text = string;
    
	return cell;
}

- (NSPersistentStore *)persistentStore {
	NSArray *persistentStores = [[managedObjectContext persistentStoreCoordinator] persistentStores];
	assert([persistentStores count] == 1);
	return [persistentStores objectAtIndex:0];
}

- (BOOL)isStoreInitialised {

	NSDictionary *metadata = [[self persistentStore] metadata];
	// TODO: Check for metadata == nill
	return ([[metadata objectForKey:@"loaded"] boolValue] == YES);
}

- (void)setStoreInitialised {
	
	NSPersistentStore *persistentStore = [self persistentStore];
	NSDictionary *metadata = [persistentStore metadata];
	// TODO: Check for metadata == nill
	NSMutableDictionary *newMetadata = [[metadata mutableCopy] autorelease];
    [newMetadata setObject:[NSNumber numberWithBool:YES] forKey:@"loaded"];
	[persistentStore setMetadata:newMetadata];
}

// Load the data store with initial data (if necessary). Will only actually do anything once.
// TODO: Probably should do this earlier in the proceedings. I would say the ThatsCampingAppDelegate would be a fairly logical place.
- (void)initialiseStore {
	if (![self isStoreInitialised]) {
		Park *park;
		Campsite *campsite;

		park = (Park *)[NSEntityDescription insertNewObjectForEntityForName:@"Park" inManagedObjectContext:managedObjectContext];
		[park setName:@"Blue Mountains"];
		[park setWebId:@"N1"];
		
		campsite = (Campsite *)[NSEntityDescription insertNewObjectForEntityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
		[campsite setName:@"Perrys Lookdown"];
		[campsite setLatitude:[NSNumber numberWithDouble:-33.598333]];
		[campsite setLongitude:[NSNumber numberWithDouble:150.351111]];
		[campsite setPark:park];
		[campsite setWebId:@"foo"];
		
		campsite = (Campsite *)[NSEntityDescription insertNewObjectForEntityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
		[campsite setName:@"Euroka Clearing"];
		[campsite setLatitude:[NSNumber numberWithDouble:-33.798333]];
		[campsite setLongitude:[NSNumber numberWithDouble:150.617778]];
		[campsite setPark:park];
		[campsite setWebId:@"foo"];
		
		campsite = (Campsite *)[NSEntityDescription insertNewObjectForEntityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
		[campsite setName:@"Murphys Glen"];
		[campsite setLatitude:[NSNumber numberWithDouble:-33.765]];
		[campsite setLongitude:[NSNumber numberWithDouble:150.501111]];
		[campsite setPark:park];
		[campsite setWebId:@"foo"];
		
		park = (Park *)[NSEntityDescription insertNewObjectForEntityForName:@"Park" inManagedObjectContext:managedObjectContext];
		[park setName:@"Kanangra-Boyd"];
		[park setWebId:@"N2"];
		
		campsite = (Campsite *)[NSEntityDescription insertNewObjectForEntityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
		[campsite setName:@"Dingo Dell"];
		[campsite setLatitude:[NSNumber numberWithDouble:-33.97375]];
		[campsite setLongitude:[NSNumber numberWithDouble:149.96516]];
		[campsite setPark:park];
		[campsite setWebId:@"foo"];
		
		// Commit the change.
		NSError *error;
		if ([managedObjectContext save:&error]) {
			// This way we only load the data into the store once
			[self setStoreInitialised];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	// If we are running on the simulator provide a fixed location
	#if TARGET_IPHONE_SIMULATOR
	newLocation = [[CLLocation alloc] initWithLatitude:-33.772609 longitude:150.624263];
	#endif

	// Now fetch the data from the store
	
	/*
	 Fetch existing events.
	 Create a fetch request; find the Campsite entity and assign it to the request; add a sort descriptor; then execute the fetch.
	 */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
	}
	
	// Loop through the campsites and calculate the distance from our current location
	for (int i=0; i < [mutableFetchResults count]; i++) {
		Campsite *campsite = [mutableFetchResults objectAtIndex:i];
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[[campsite latitude] doubleValue] longitude:[[campsite longitude] doubleValue]];
		[campsite setDistance:[NSNumber numberWithDouble:[newLocation getDistanceFrom:loc]]];
		[loc release];
	}
	
	// Commit the change.
	if (![managedObjectContext save:&error]) {
		// Handle the error.
	}
	
	// Sort the campsites by distance
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[mutableFetchResults sortUsingDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
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
	[managedObjectContext release];
	[campsitesArray release];
    [locationManager release];
    [super dealloc];
}


@end

