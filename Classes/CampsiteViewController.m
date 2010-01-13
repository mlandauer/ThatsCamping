#import "CampsiteViewController.h"
#import "ParkViewController.h"

@implementation CampsiteViewController

@synthesize campsite, parkClickable;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [campsite shortName];

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
		return 1;
	else if (section == 2)
		return 2;
	else if (section == 3)
		return 3;
	// Doing this to avoid compiler warning
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 2) {
		return @"Facilities";
	}
	else if (section == 3) {
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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	// This is the default unless overridden below
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Name";
				cell.detailTextLabel.text = [campsite longName];
				break;
			case 1:
				cell.textLabel.text = @"Park";
				cell.detailTextLabel.text = [[campsite park] longName];
				if (parkClickable) {
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
				}
				break;
		}
	}
	else if (indexPath.section == 1) {
		cell.textLabel.text = @"Directions to campsite";
	}
	else if (indexPath.section == 2) {
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
		
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Has:";
				cell.detailTextLabel.text = [present componentsJoinedByString:@", "];
				break;
			case 1:
				cell.textLabel.text = @"Doesn't have:";
				cell.detailTextLabel.text = [notPresent componentsJoinedByString:@", "];
				break;

		}
	}
	else if (indexPath.section == 3) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Caravans";
				cell.detailTextLabel.text = [self boolNumberAsText:[campsite caravans]];
				break;
			case 1:
				cell.textLabel.text = @"Trailers";
				cell.detailTextLabel.text = [self boolNumberAsText:[campsite trailers]];
				break;
			case 2:
				cell.textLabel.text = @"Car";
				cell.detailTextLabel.text = [self boolNumberAsText:[campsite car]];
				break;
		}
	}
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 1 && parkClickable) {
		ParkViewController *parkViewController = [[ParkViewController alloc] initWithNibName:@"ParkViewController" bundle:nil];
		parkViewController.currentPark = [campsite park];
		[self.navigationController pushViewController:parkViewController animated:YES];
		[parkViewController release];
	}
	else if (indexPath.section == 1) {
		NSString *urlString = [[NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@@%@,%@)",
								campsite.shortName, campsite.latitude, campsite.longitude]
							   stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];		
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
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

