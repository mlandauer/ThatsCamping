#import "CampsiteViewController.h"
#import "ParkViewController.h"

@implementation CampsiteViewController

@synthesize campsite, parkClickable, locationManager, tableView, directionsButton;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [campsite shortName];

	// If this campsite doesn't have any location data then disable the "directions to campsite" button
	if (campsite.latitude == nil || campsite.longitude == nil) {
		directionsButton.enabled = NO;
	}
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 2;
	else if (section == 1)
		return [[self facilitiesFields] count];
	else if (section == 2)
		return [[self accessFields] count];
	// Doing this to avoid compiler warning
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 1) {
		return @"Facilities";
	}
	else if (section == 2) {
		return @"Access";
	}
	else {
		return nil;
	}

}

- (NSString *) boolNumberAsText:(NSNumber *)n
{
	if ([n boolValue]) {
		return @"Yes";
	}
	else {
		return @"No";
	}
}

// Returns the field text and values for the facilities
- (NSArray *)facilitiesFields 
{
	// Split the facilities into two list: those that this campsite has and those it doesn't.
	NSMutableArray *present = [NSMutableArray arrayWithCapacity:3];
	NSMutableArray *notPresent = [NSMutableArray arrayWithCapacity:3];
	if ([campsite hasFlushToilets]) {
		[present addObject:@"flush toilets"];
	}
	else if ([campsite hasNonFlushToilets]) {
		[present addObject:@"non-flush toilets"];
	}
	else if (![campsite hasToilets]) {
		[notPresent addObject:@"toilets"];
	}
	else {
		assert(false);
	}
	if ([[campsite picnicTables] boolValue]) {
		[present addObject:@"picnic tables"];
	}
	else {
		[notPresent addObject:@"picnic tables"];
	}
	// TODO: show whether you need to bring your own firewood elsewhere
	// Like "You will need to bring firewood (if you want to use the wood BBQs) and drinking water"
	if ([campsite hasWoodBarbecues]) {
		[present addObject:@"wood BBQs"];
	}
	else if	([campsite hasGasElectricBarbecues]) {
		[present addObject:@"gas/electric BBQs"];
	}
	else if (![campsite hasBarbecues]) {
		[notPresent addObject:@"BBQs"];
	}
	else {
		assert(false);
	}
	if ([campsite hasHotShowers]) {
		[present addObject:@"hot showers"];
	}
	else if ([campsite hasColdShowers]) {
		[present addObject:@"cold showers"];
	}
	else if (![campsite hasShowers]) {
		[notPresent addObject:@"showers"];
	}
	else {
		assert(false);
	}
	if ([[campsite drinkingWater] boolValue]) {
		[present addObject:@"drinking water"];
	}
	else {
		[notPresent addObject:@"drinking water"];
	}
	
	NSDictionary *presentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Has", @"textLabel",
									[present componentsJoinedByString:@", "], @"detailTextLabel", nil];
	NSDictionary *notPresentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"But no", @"textLabel",
									   [notPresent componentsJoinedByString:@", "], @"detailTextLabel", nil];
	NSArray	*fields = [NSArray arrayWithObjects:presentDictionary, notPresentDictionary, nil];
	return fields;
}

- (NSArray *)accessFields
{
	NSMutableArray *access = [NSMutableArray arrayWithCapacity:3];
	NSMutableArray *noAccess = [NSMutableArray arrayWithCapacity:3];
	if ([campsite.caravans boolValue]) {
		[access addObject:@"Caravans"];
	}
	else {
		[noAccess addObject:@"Caravans"];
	}
	if ([campsite.trailers boolValue]) {
		[access addObject:@"Trailers"];
	}
	else {
		[noAccess addObject:@"Trailers"];
	}
	if ([campsite.car boolValue]) {
		[access addObject:@"Car camping"];
	}
	else {
		[noAccess addObject:@"Car camping"];
	}

	NSDictionary *accessDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Suits", @"textLabel",
									   [access componentsJoinedByString:@", "], @"detailTextLabel", nil];
	NSDictionary *noAccessDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"But not", @"textLabel",
										  [noAccess componentsJoinedByString:@", "], @"detailTextLabel", nil];
	NSArray	*fields = [NSArray arrayWithObjects:accessDictionary, noAccessDictionary, nil];
	return fields;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Cell"] autorelease];
    }
    UITableViewCell *cellDefault = [aTableView dequeueReusableCellWithIdentifier:@"CellDefault"];
    if (cellDefault == nil) {
        cellDefault = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellDefault"] autorelease];
    }
	
	// These are the defaults unless overridden below
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.detailTextLabel.numberOfLines = 1;
	
	if (indexPath.section == 0) {
		cell = cellDefault;
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = [campsite longName];
				break;
			case 1:
				cell.textLabel.text = [[campsite park] longName];
				if (parkClickable) {
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
				}
				break;
		}
	}
	else if (indexPath.section == 1) {
		NSDictionary *field = [[self facilitiesFields] objectAtIndex:indexPath.row];
		cell.textLabel.text = [field objectForKey:@"textLabel"];
		cell.detailTextLabel.text = [field objectForKey:@"detailTextLabel"];
		cell.detailTextLabel.numberOfLines = 2;
	}
	else if (indexPath.section == 2) {
		NSMutableArray *access = [NSMutableArray arrayWithCapacity:3];
		NSMutableArray *noAccess = [NSMutableArray arrayWithCapacity:3];
		if ([campsite.caravans boolValue]) {
			[access addObject:@"Caravans"];
		}
		else {
			[noAccess addObject:@"Caravans"];
		}
		if ([campsite.trailers boolValue]) {
			[access addObject:@"Trailers"];
		}
		else {
			[noAccess addObject:@"Trailers"];
		}
		if ([campsite.car boolValue]) {
			[access addObject:@"Car camping"];
		}
		else {
			[noAccess addObject:@"Car camping"];
		}
		
		NSDictionary *field = [[self accessFields] objectAtIndex:indexPath.row];
		cell.textLabel.text = [field objectForKey:@"textLabel"];
		cell.detailTextLabel.text = [field objectForKey:@"detailTextLabel"];
		cell.detailTextLabel.numberOfLines = 2;
	}
    
    return cell;
}

- (IBAction) showDirections
{
	// Get the current location
	CLLocationCoordinate2D coordinate = [locationManager location].coordinate;
	NSString *urlString = [[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=you+are+here@%f,%f&daddr=%@@%@,%@)",
							coordinate.latitude, coordinate.longitude,
							campsite.shortName, campsite.latitude, campsite.longitude]
						   stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];		
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 1 && parkClickable) {
		ParkViewController *parkViewController = [[ParkViewController alloc] initWithNibName:@"ParkViewController" bundle:nil];
		parkViewController.currentPark = [campsite park];
		// TODO: Fix (get rid of) this location passing around nonsense
		parkViewController.locationManager = locationManager;
		[self.navigationController pushViewController:parkViewController animated:YES];
		[parkViewController release];
	}
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:aTableView didSelectRowAtIndexPath:indexPath];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

