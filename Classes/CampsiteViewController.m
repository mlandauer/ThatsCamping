//
// Copyright (C) 2010 Matthew Landauer and Katherine Szuminska
//

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
    return 3;
}

int const NAMES_SECTION_INDEX = 0;
int const FACILITIES_SECTION_INDEX = 1;
int const ACCESS_SECTION_INDEX = 2;

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == NAMES_SECTION_INDEX) {
		if ([campsite.textDescription isEqualToString:@""]) {
			return 2;
		}
		else {
			return 3;
		}
	}
	else if (section == FACILITIES_SECTION_INDEX)
		return [[self facilitiesFields] count];
	else if (section == ACCESS_SECTION_INDEX)
		return [[self accessFields] count];
	// Doing this to avoid compiler warning
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == FACILITIES_SECTION_INDEX) {
		return @"Facilities";
	}
	else if (section == ACCESS_SECTION_INDEX) {
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
									[self textFromList:present joinWord:@"and"], @"detailTextLabel", nil];
	NSMutableDictionary *notPresentDictionary = [NSMutableDictionary dictionaryWithObject:
												 [self textFromList:notPresent joinWord:@"and"] forKey:@"detailTextLabel"];
	NSArray	*fields;
	
	if ([present count] == 0) {
		[notPresentDictionary setObject:@"No" forKey:@"textLabel"];
		fields = [NSArray arrayWithObject:notPresentDictionary];
	}
	else if ([notPresent count] == 0) {
		fields = [NSArray arrayWithObject:presentDictionary];
	}
	else {
		[notPresentDictionary setObject:@"But no" forKey:@"textLabel"];
		fields = [NSArray arrayWithObjects:presentDictionary, notPresentDictionary, nil];
	}
	return fields;
}

// Turn an array of @"Apples", @"Oranges", @"Bananas" into @"Apples, Oranges and Bananas"
- (NSString *) textFromList:(NSArray *)list joinWord:(NSString *)joinWord
{
	if ([list count] > 1) {
		// Join together all but the last item with commas
		NSRange range;
		range.location = 0;
		range.length = [list count] - 1;
		NSArray *first = [list subarrayWithRange:range];
		NSString *firstString = [first componentsJoinedByString:@", "];
		NSString *lastString = [list objectAtIndex:([list count] - 1)];
		return [NSString stringWithFormat:@"%@ %@ %@", firstString, joinWord, lastString];
	}
	else {
		return [list componentsJoinedByString:@", "];
	}
}

- (NSArray *)accessFields
{
	NSMutableArray *access = [NSMutableArray arrayWithCapacity:3];
	NSMutableArray *noAccess = [NSMutableArray arrayWithCapacity:3];
	if ([campsite.caravans boolValue]) {
		[access addObject:@"caravans"];
	}
	else {
		[noAccess addObject:@"caravans"];
	}
	if ([campsite.trailers boolValue]) {
		[access addObject:@"trailers"];
	}
	else {
		[noAccess addObject:@"trailers"];
	}
	if ([campsite.car boolValue]) {
		[access addObject:@"car camping"];
	}
	else {
		[noAccess addObject:@"car camping"];
	}

	NSArray	*fields;
	NSDictionary *accessDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"For", @"textLabel",
										[self textFromList:access joinWord:@"and"], @"detailTextLabel", nil];
	NSMutableDictionary *noAccessDictionary = [NSMutableDictionary dictionaryWithObject:[self textFromList:noAccess joinWord:@"and"]
																		  forKey:@"detailTextLabel"];
	// Have some special handling when some of the fields are blank
	if ([access count] == 0) {
		[noAccessDictionary setObject:@"Not for" forKey:@"textLabel"];
		fields = [NSArray arrayWithObject:noAccessDictionary];
	}
	else if ([noAccess count] == 0) {
		fields = [NSArray arrayWithObject:accessDictionary];
	}
	else {
		[noAccessDictionary setObject:@"But not for" forKey:@"textLabel"];
		fields = [NSArray arrayWithObjects:accessDictionary, noAccessDictionary, nil];
	}
	
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
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cellDefault.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.numberOfLines = 1;
	cellDefault.textLabel.numberOfLines = 1;
	
	if (indexPath.section == NAMES_SECTION_INDEX) {
		cell = cellDefault;
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = [campsite longName];
				cell.textLabel.numberOfLines = 2;
				break;
			case 1:
				cell.textLabel.text = [[campsite park] longName];
				if (parkClickable) {
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				}
				break;
			case 2:
				cell.textLabel.text = campsite.textDescription;
				cell.textLabel.numberOfLines = 0;
				UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:13.0];
				cell.textLabel.font = cellFont;
				break;

		}
	}
	else if (indexPath.section == FACILITIES_SECTION_INDEX || indexPath.section == ACCESS_SECTION_INDEX) {
		NSArray *fields;
		if (indexPath.section == FACILITIES_SECTION_INDEX) {
			fields = [self facilitiesFields];
		}
		else if (indexPath.section == ACCESS_SECTION_INDEX) {
			fields = [self accessFields];
		}

		NSDictionary *field = [fields objectAtIndex:indexPath.row];
		cell.textLabel.text = [field objectForKey:@"textLabel"];
		cell.detailTextLabel.text = [field objectForKey:@"detailTextLabel"];
		cell.detailTextLabel.numberOfLines = 2;
		cell.textLabel.numberOfLines = 2;
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == NAMES_SECTION_INDEX && indexPath.row == 2) {
		NSString *cellText = campsite.textDescription;
		UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:13.0];
		CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
		CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		
		return labelSize.height + 20;
	}
	return aTableView.rowHeight;
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
	if (indexPath.section == NAMES_SECTION_INDEX && indexPath.row == 1 && parkClickable) {
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

