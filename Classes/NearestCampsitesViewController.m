// The table view controller responsible for displaying the list of events, supporting additional functionality:
//
// Copyright (C) 2010 Matthew Landauer and Katherine Szuminska
//

#import "NearestCampsitesViewController.h"
#import "ThatsCampingAppDelegate.h"
#import "Campsite.h"
#import "Park.h"
#import "CampsiteViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyAnnotationView.h"
#import "AboutViewController.h"

@implementation NearestCampsitesViewController


@synthesize campsitesArray, locationManager, managedObjectContext, tableView, containerView, mapView, activityIndicatorView;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Set the title.
    self.title = @"Camping near you in NSW";
	
	//self.tableView.allowsSelection = NO;
    [containerView addSubview:tableView];
	
	// Start the location manager.
	useLocation = YES;
	[[self locationManager] startUpdatingLocation];
	[activityIndicatorView startAnimating];
	
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

	// Uncomment the line below if you want to test the situation where the user says "Don't use my location" on the simulator
	//[self doNotUseLocation];
}

// Returns the map view. Only created when it's needed as it takes up a lot of CPU cycles updating
- (MKMapView *)mapView
{
	if (mapView == nil) {
		// Create the map view
		mapView = [[MKMapView alloc] initWithFrame:containerView.frame];
		mapView.delegate = self;
		
		// Shows the user location
		mapView.showsUserLocation = YES;
		
		// Fetch all the campsites that have geo data attached
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"latitude != NULL && longitude != NULL"];
		[request setPredicate:predicate];
		
		NSError *error = nil;
		NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
		if (fetchResults == nil) {
			// Handle the error.
		}
		// Add the campsites to the map
		[mapView addAnnotations:fetchResults];

		// Make the default map view show approximately one degree of latitude and longitude (approx 100km)
		MKCoordinateSpan span = {1.0, 1.0};
		MKCoordinateRegion region;
		region.span = span;
		
		NSIndexPath *selected = [tableView indexPathForSelectedRow];
		Campsite *campsite = nil;
		if (selected != nil) {
			campsite = [campsitesArray objectAtIndex:selected.row];
		}

		// If a campsite is selected and it has position information use it as the centre of the map
		if (campsite != nil && campsite.longitude != nil && campsite.latitude != nil) {
			region.center = campsite.coordinate;
			// TODO: Should select the campsite on the map as well but I can't get this to work
		}
		// Otherwise, if the user is allow their location to be used put them at the centre of the map
		else if (useLocation) {
			// Use the current location as the centre of the map
			region.center = [locationManager location].coordinate;;
		}
		// Otherwise just show all of NSW
		else {
			MKCoordinateRegion nswRegion = {{-32.83, 150.14}, {8.0, 8.0}};
			region = nswRegion;
		}
		
		mapView.region = region;
		
		// And finally... add it to the containerView (but hidden)
		mapView.hidden = YES;
		[containerView addSubview:mapView];
	}
	return mapView;
}

- (void)viewDidUnload {
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
	self.campsitesArray = nil;
	self.locationManager = nil;
}

- (IBAction)listOrMapChanged:(id)sender
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	if ([sender selectedSegmentIndex] == 0) {
		tableView.hidden = NO;
		self.mapView.hidden = YES;
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:containerView cache:TRUE];
	}
	else {
		tableView.hidden = YES;
		self.mapView.hidden = NO;
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:containerView cache:TRUE];
	}
	[UIView commitAnimations];
}

- (IBAction)aboutButtonPressed:(id)sender
{
	AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	aboutViewController.delegate = self;
	[self presentModalViewController:aboutViewController animated:YES];
	[aboutViewController release];
}

// When the about page says it's ready to be closed it calls this (via the delegate)
- (void)aboutDone
{
	[self dismissModalViewControllerAnimated:YES];
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

- (NSString *)bearingInWords:(float)bearing
{
	// Dividing the compass into 8 sectors that are centred on north
	int sector = fmod(bearing + 22.5, 360.0) / 45.0;
	NSArray *sectorNames = [NSArray arrayWithObjects:@"N", @"NE", @"E", @"SE", @"S", @"SW", @"W", @"NW", nil];
	return [sectorNames objectAtIndex:sector];
}

- (MKAnnotationView *)mapView:(MKMapView *)thisMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	// If this is the current location view then don't change it from the default
	if (annotation == thisMapView.userLocation) {
		return nil;
	}

	static NSString *identifier = @"Annotation";
	MyAnnotationView *view = (MyAnnotationView *) [thisMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (view == nil) {
		view = [[[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
	}
	view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	view.canShowCallout = YES;
	view.delegate = self;
	return view;
}

// This is called from MyAnnotationView when a user clicks on a pin on the map
- (void) annotationSelected:(id <MKAnnotation>)annotation
{
	Campsite *campsite = (Campsite *) annotation;
	// TODO: There must be a more concise way of doing this
	NSUInteger indexes[2];
	indexes[0] = 0;
	indexes[1] = [campsitesArray indexOfObject:campsite];
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];

	if (![[tableView indexPathForSelectedRow] isEqual:indexPath]) {
		[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
	}
}

- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [thisTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		UITableViewCellStyleValue1;
    }
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
	// Get the campsite corresponding to the current index path and configure the table view cell.
	Campsite *campsite = (Campsite *)[campsitesArray objectAtIndex:indexPath.row];
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", [campsite shortName], [[campsite park] shortName]];
	cell.detailTextLabel.numberOfLines = 2;

	// Only show the distance if the user is allowing us to use their location
	if (useLocation) {
		static NSNumberFormatter *numberFormatter = nil;
		if (numberFormatter == nil) {
			numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
			[numberFormatter setMaximumFractionDigits:0];
		}

		NSString *string = [NSString stringWithFormat:@"%@ %@",
							[self distanceInWords:[[campsite distance] doubleValue]],
							[self bearingInWords:[[campsite bearing] floatValue]]];
		cell.textLabel.text = string;
    }
	else {
		cell.textLabel.text = @"";
	}

	return cell;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	CampsiteViewController *campsiteController = [[CampsiteViewController alloc] initWithNibName:@"CampsiteViewController" bundle:nil];
    campsiteController.campsite = view.annotation;
	campsiteController.parkClickable = YES;
	// Really ugly telling the next controller the location like this
	// TODO: Fix this silly!
	campsiteController.locationManager = locationManager;
    [[self navigationController] pushViewController:campsiteController animated:YES];
    [campsiteController release];	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Campsite *campsite = [campsitesArray objectAtIndex:indexPath.row];
	// If this campsite is not currently selected on the map
	if (mapView != nil && ((Campsite *) [[mapView selectedAnnotations] objectAtIndex:0]) != campsite) {
		if (campsite.latitude != nil && campsite.longitude != nil) {
			// Center the map on the campsite and select it
			mapView.centerCoordinate = campsite.coordinate;
			[mapView selectAnnotation:campsite animated:NO];
		}
		else {
			// The currently selected campsite has no position, so isn't on the map. So, unselect the previously selected one
			[mapView deselectAnnotation:[[mapView selectedAnnotations] objectAtIndex:0] animated:NO];
		}
	}
	
	CampsiteViewController *campsiteController = [[CampsiteViewController alloc] initWithNibName:@"CampsiteViewController" bundle:nil];
	campsiteController.campsite = campsite;
	campsiteController.parkClickable = YES;
	// Really ugly telling the next controller the location like this
	// TODO: Fix this silly!
	campsiteController.locationManager = locationManager;
    [[self navigationController] pushViewController:campsiteController animated:YES];
    [campsiteController release];
}

- (void)tableView:(UITableView *)thisTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:thisTableView didSelectRowAtIndexPath:indexPath];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	[activityIndicatorView stopAnimating];

	// If we are running on the simulator provide a fixed location
	#if TARGET_IPHONE_SIMULATOR
	newLocation = [[CLLocation alloc] initWithLatitude:-33.772609 longitude:150.624263];
	#endif

	// Set the centre of the map to the current location (but only if no campsite is selected)
	if (mapView != nil && [tableView indexPathForSelectedRow] == nil) {
		[mapView setCenterCoordinate:newLocation.coordinate animated:YES];
	}
	
	// Now fetch the data from the store
	
	/*
	 Fetch existing events.
	 Create a fetch request; find the Campsite entity and assign it to the request; add a sort descriptor; then execute the fetch.
	 */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Some campsites don't have a location set. For this list of nearest campsites don't include those.
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"latitude != NULL AND longitude != NULL"];
	[request setPredicate:predicate];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
	}
	
	NSEnumerator *enumerator = [mutableFetchResults objectEnumerator];
	id campsite;
	while ((campsite = [enumerator nextObject])) {
		[campsite setDistance:[campsite distanceFrom:newLocation]];
		[campsite setBearing:[campsite bearingFrom:newLocation]];
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

// The user explicitly said, "No, I don't want you to use my location".
- (void)doNotUseLocation
{
	useLocation = NO;
	self.title = @"Camping in NSW";
	[[self locationManager] stopUpdatingLocation];
	[activityIndicatorView stopAnimating];

	// Show the campsites in the table in alphabetical order by campsite name
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shortName" ascending:YES];
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
	
	// Now show the new data
	[[self tableView] reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if (error.code == kCLErrorDenied) {
		[self doNotUseLocation];
	}
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
	[locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
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

